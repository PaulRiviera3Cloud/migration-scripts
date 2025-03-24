#!/usr/bin/env pwsh

# =========== Created with CLI version 1.12.0 ===========

function Exec {
    param (
        [scriptblock]$ScriptBlock
    )
    & @ScriptBlock
    if ($lastexitcode -ne 0) {
        exit $lastexitcode
    }
}

if (-not $env:GH_PAT) {
    Write-Error "GH_PAT environment variable must be set to a valid GitHub Personal Access Token with the appropriate scopes. For more information see https://docs.github.com/en/migrations/using-github-enterprise-importer/preparing-to-migrate-with-github-enterprise-importer/managing-access-for-github-enterprise-importer#creating-a-personal-access-token-for-github-enterprise-importer"
    exit 1
} else {
    Write-Host "GH_PAT environment variable is set and will be used to authenticate to GitHub."
}

if (-not $env:BBS_PASSWORD) {
    Write-Error "BBS_PASSWORD environment variable must be set to a valid password that will be used to call Bitbucket Server/Data Center API's to generate a migration archive."
    exit 1
} else {
    Write-Host "BBS_PASSWORD environment variable is set and will be used to authenticate to Bitbucket Server/Data Center APIs."
}

if (-not $env:BBS_USERNAME) {
    Write-Error "BBS_USERNAME environment variable must be set to a valid user that will be used to call Bitbucket Server/Data Center API's to generate a migration archive."
    exit 1
} else {
    Write-Host "BBS_USERNAME environment variable is set and will be used to authenticate to Bitbucket Server/Data Center APIs."
}

if (-not $env:AZURE_STORAGE_CONNECTION_STRING) {
    Write-Error "AZURE_STORAGE_CONNECTION_STRING environment variable must be set to a valid Azure Storage Connection String that will be used to upload the migration archive to Azure Blob Storage."
    exit 1
} else {
    Write-Host "AZURE_STORAGE_CONNECTION_STRING environment variable is set and will be used to upload the migration archive to Azure Blob Storage."
}

# =========== Project: TES ===========

Exec { gh bbs2gh migrate-repo --bbs-server-url "" --bbs-project "" --bbs-repo "" --ssh-user "" --ssh-private-key "" --ssh-port 22 --github-org "" --github-repo "" --target-repo-visibility private }
Exec { gh bbs2gh migrate-repo --bbs-server-url "" --bbs-project "" --bbs-repo "" --ssh-user "" --ssh-private-key "" --ssh-port 22 --github-org "" --github-repo "" --target-repo-visibility private }
Exec { gh bbs2gh migrate-repo --bbs-server-url "" --bbs-project "" --bbs-repo "" --ssh-user "" --ssh-private-key "" --ssh-port 22 --github-org "" --github-repo "" --target-repo-visibility private }
Exec { gh bbs2gh migrate-repo --bbs-server-url "" --bbs-project "" --bbs-repo "" --ssh-user "" --ssh-private-key "" --ssh-port 22 --github-org "" --github-repo "" --target-repo-visibility private }


