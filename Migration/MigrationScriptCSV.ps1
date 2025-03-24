#!/usr/bin/env pwsh

# =========== Created with CLI version 1.12.0 ===========

# ================================
# Variables (Modify as Needed)
# ================================

# Bitbucket Server Information
$bbsServerUrl = ""  # Replace with your Bitbucket Server URL
$bbsServerIP = ""               # IP address of the Bitbucket Server

# SSH Credentials for Bitbucket Server
$sshUser = ""  # Replace with actual SSH username
$privateKeyPath = ""  # Path to SSH private key

# Archive Path Configuration
$remoteArchiveDir = ""  # Bitbucket archive path
$localDownloadDir = ""  # Local directory for storing downloaded archive

# GitHub Organization Details
$githubOrg = ""  # Replace with your GitHub organization

# Required Environment Variables
$requiredEnvVars = @("GH_PAT", "BBS_USERNAME", "BBS_PASSWORD")

# ================================
# Function: Execute Commands Safely
# ================================
function Exec {
    param (
        [scriptblock]$ScriptBlock
    )
    & @ScriptBlock
    if ($lastexitcode -ne 0) {
        exit $lastexitcode
    }
}

# ================================
# Validate Required Environment Variables
# ================================
foreach ($var in $requiredEnvVars) {
    if (-not (Get-Item -Path Env:\$var -ErrorAction SilentlyContinue)) {
        Write-Error "$var environment variable must be set."
        exit 1
    } else {
        Write-Host "$var environment variable is set."
    }
}

# ================================
# Load Repositories from CSV File
# ================================
$csvFile = "repos.csv"

if (-not (Test-Path $csvFile)) {
    Write-Error "CSV file $csvFile not found! Please provide a valid file."
    exit 1
}

$repos = Import-Csv -Path $csvFile

foreach ($repo in $repos) {
    $bbsProject = $repo.bbs_project
    $bbsRepo = $repo.bbs_repo
    $githubRepo = $repo.github_repo

    Write-Host "Starting migration process for Bitbucket repo: $bbsProject/$bbsRepo to GitHub: $githubOrg/$githubRepo"

    # ================================
    # Step 1: Generate Migration Archive
    # ================================
    Write-Host "Generating migration archive for $bbsProject/$bbsRepo..."
    Exec {
        gh bbs2gh migrate-repo `
            --bbs-server-url "$bbsServerUrl" `
            --bbs-project "$bbsProject" `
            --bbs-repo "$bbsRepo"
    }

    # ================================
    # Step 2: Fetch Latest Archive Name
    # ================================
    Write-Host "Fetching latest archive file from Bitbucket Server..."
    $latestArchiveFile = ssh -i "$privateKeyPath" "$sshUser@$bbsServerIP" "ls -t $remoteArchiveDir | head -n 1"

    if (-not $latestArchiveFile) {
        Write-Error "No archive files found in Bitbucket export directory!"
        exit 1
    }

    Write-Host "Latest archive file: $latestArchiveFile"

    # Define the local path where the file will be stored
    $localArchivePath = "$localDownloadDir\$latestArchiveFile"

    # ================================
    # Step 3: Copy Archive from Bitbucket Server to Local Machine
    # ================================
    Write-Host "Copying $latestArchiveFile from Bitbucket Server to local machine..."
    Exec {
        $scpCommand = "scp -i `"$privateKeyPath`" `"$sshUser@$bbsServerIP`:`$remoteArchiveDir/$latestArchiveFile`" `"$localDownloadDir/`""
        Write-Host "Executing: $scpCommand"
        Invoke-Expression $scpCommand
    }

    # ================================
    # Step 4: Start Final Migration with Archive Path
    # ================================
    Write-Host "Starting Final Migration for $bbsProject/$bbsRepo..."
    Exec {
        gh bbs2gh migrate-repo `
            --archive-path "$localArchivePath" `
            --github-org "$githubOrg" `
            --github-repo "$githubRepo" `
            --bbs-server-url "$bbsServerUrl" `
            --bbs-project "$bbsProject" `
            --bbs-repo "$bbsRepo" `
            --azure-storage-connection-string "$env:AZURE_STORAGE_CONNECTION_STRING" `
            --verbose `
            --target-repo-visibility private
    }
}

Write-Host "Migration script completed!"
