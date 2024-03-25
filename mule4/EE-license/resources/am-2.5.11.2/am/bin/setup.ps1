#!/usr/bin/pwsh
param(
    [Alias('h')][switch]$SHOW_HELP,
    [Alias('m')][string]$HOME_DIR=""
)

$ErrorActionPreference = "Stop"

If ($SHOW_HELP) {
    Write-Host "DESCRIPTION: Setup Anypoint Monitoring FileBeat"
    Write-Host "Usage: .\$($MyInvocation.MyCommand) [options]"
    Write-Host ""
    Write-Host "options:"
    Write-Host "-h          show help and exit"
    Write-Host "-m [DIR]    set home directory - defaults to MULE_HOME"
    Write-Host ""

    exit 0
}

if ([string]::IsNullOrEmpty($HOME_DIR) -Or (-Not (Test-Path -Path $HOME_DIR))) {
    if (-Not ([string]::IsNullOrEmpty($Env:MULE_HOME)) -And (Test-Path -Path $Env:MULE_HOME)) {
        $HOME_DIR=$Env:MULE_HOME
    }
    else {
        cd $(split-path -parent $MyInvocation.MyCommand.Definition)
        cd ..\..
        $HOME_DIR=Convert-Path $pwd
    }
}

Write-Host "MULE_HOME is set to ${HOME_DIR}"

$AM_HOME="${HOME_DIR}\am"

function Restart-AgentStandalone {
    Invoke-Expression "${AM_HOME}\bin\am.ps1 -m $HOME_DIR -a restart_with_recovery"
    Write-Host "To start, stop or restart monitoring use the following command: .\am.ps1 -a start|stop|restart"
}

function Restart-AgentService {
    Invoke-Expression "${AM_HOME}\bin\am-service.ps1 -m $HOME_DIR -a restart_with_recovery"
    Write-Host "To start, stop or restart monitoring as a service use the following command: .\am-service.ps1 -a start|stop|restart"
}

$SERVICE_NAME="am-filebeat"
$attempts = 30
Write-Host "Waiting for Anypoint Monitoring configuration..."
while ($attempts -gt 0) {
    if (Test-Path $AM_HOME\config\filebeat.yml) {
        Write-Host "Anypoint Monitoring configuration is ready"

        Invoke-Expression "${AM_HOME}\bin\am.ps1 -m $HOME_DIR -a check"

        if (Get-Service $SERVICE_NAME -ErrorAction SilentlyContinue) {
            Restart-AgentService
        }
        else {
            Restart-AgentStandalone
        }

        exit 0
    }

    $attempts--
    Start-Sleep 10
}

Write-Host "Anypoint Monitoring configuration not found. The logs and the metric won't send to the platform."
