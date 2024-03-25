#!/usr/bin/pwsh
param(
    [Alias('h')][switch]$SHOW_HELP,
    [Alias('m')][string]$HOME_DIR=""
)

$ErrorActionPreference = "Stop"

If ($SHOW_HELP) {
    Write-Host "DESCRIPTION: Uninstall Anypoint Monitoring FileBeat"
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
        $HOME_DIR=$pwd
    }
}

Write-Host "MULE_HOME is set to ${HOME_DIR}"

$AM_HOME="${HOME_DIR}\am"


function Check-File-Status($filePath) {
    if ((Test-Path -Path $filePath) -eq $false) {
        return $false
    }

    $oFile = New-Object System.IO.FileInfo $filePath

    try {
        $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

        if ($oStream) {
            $oStream.Close()
        }
        $true
    } catch {
        write-host "Cannot delete agent file is locked"
        return $false
    }
}

function Remove-Files($path) {
    Get-ChildItem -Path $path -ErrorAction SilentlyContinue | ForEach-Object {
        $status = Check-File-Status("$_")
        if($status){
            Remove-Item $_ -Force
        }
    }
}

function Remove-ConfigFiles {
    Remove-Item $AM_HOME\config\filebeat.yml -Force -ErrorAction SilentlyContinue
    Remove-Item $AM_HOME\config\filebeat.yml.md5 -Force -ErrorAction SilentlyContinue
    Remove-Item $AM_HOME\config\server.id -Force -ErrorAction SilentlyContinue
    Remove-Item $AM_HOME\config\proxy.url -Force -ErrorAction SilentlyContinue
    Remove-Item $AM_HOME\config\certs -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item $AM_HOME\config\prospectors -Force -Recurse -ErrorAction SilentlyContinue
}

function Remove-Agent {
    if (Test-Path $HOME_DIR\lib\mule\mule-core-4*) {
        Remove-Files("$HOME_DIR\server-plugins\mule-agent-plugin\lib\mule-agent-dias-*.jar")
        Remove-Files("$HOME_DIR\server-plugins\mule-agent-plugin\lib\analytics-metrics-collector-*.jar")
        Remove-Files("$HOME_DIR\server-plugins\mule-agent-plugin\lib\modules\mule-agent-dias-*.jar")
        Remove-Files("$HOME_DIR\server-plugins\mule-agent-plugin\lib\modules\analytics-metrics-collector-*.jar")
    }
    else {
        Remove-Files("$HOME_DIR\plugins\mule-agent-plugin\lib\modules\mule-agent-dias-*.jar")
        Remove-Files("$HOME_DIR\plugins\mule-agent-plugin\lib\modules\analytics-metrics-collector-*.jar")
    }
}

function Stop-AgentStandalone {
    Invoke-Expression "${AM_HOME}\bin\am.ps1 -m $HOME_DIR -a stop"
}

$SERVICE_NAME="am-filebeat"
$LEGACY_SERVICE_NAME="filebeat"
$SCHEDULED_TASK_NAME="Anypoint Monitoring Filebeat Watcher"

function Stop-AgentService($name) {
    $service = Get-WmiObject -Class Win32_Service -Filter "name='$name'"
    $service.StopService()
    Start-Sleep -s 1
    $service.delete()
    if (Get-ScheduledTask $SCHEDULED_TASK_NAME -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $SCHEDULED_TASK_NAME -Confirm:$false
    }
}

Remove-ConfigFiles
Remove-Agent

if (Get-Service $SERVICE_NAME -ErrorAction SilentlyContinue) {
    Stop-AgentService $SERVICE_NAME
}
elseif (Get-Service $LEGACY_SERVICE_NAME -ErrorAction SilentlyContinue) {
    Stop-AgentService $LEGACY_SERVICE_NAME
}
else {
    Stop-AgentStandalone
}
