#!/usr/bin/pwsh
param(
    [Alias('h')][switch]$SHOW_HELP,
    [Alias('m')][string]$HOME_DIR="",
    [Alias('p')][string]$PROXY_URL,
    [Alias('s')][string]$SERVER_ID
)

$ErrorActionPreference = "Stop"

If ($SHOW_HELP) {
    Write-Host "DESCRIPTION: Install Anypoint Monitoring FileBeat"
    Write-Host "Usage: .\$($MyInvocation.MyCommand) [options]"
    Write-Host ""
    Write-Host "options:"
    Write-Host "-h          show help and exit"
    Write-Host "-m [DIR]    set home directory - defaults to MULE_HOME"
    Write-Host "-p [URL]    set SOCKS5 proxy server URL"
    Write-Host "            Example: socks5://user:password@socks5-server:1080"
    Write-Host "-s [ID]     set server ID"
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

$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

function Initialize-ConfigFiles {
    Remove-Item $AM_HOME\config\filebeat.yml -Force -ErrorAction SilentlyContinue
    if (!$SERVER_ID) {
        Remove-Item $AM_HOME\config\server.id -Force -ErrorAction SilentlyContinue
    }
    else {
        Set-Content -Value $Utf8NoBomEncoding.GetBytes($SERVER_ID) -Encoding Byte -Path $AM_HOME\config\server.id
    }
}

function Invoke-ConfigureProxyUrl {
    Remove-Item $AM_HOME\config\proxy.url -Force -ErrorAction SilentlyContinue
    if ($PROXY_URL) {
        Set-Content -Value $Utf8NoBomEncoding.GetBytes($PROXY_URL) -Encoding Byte -Path $AM_HOME\config\proxy.url
    }
}

function Invoke-ConfigureAgent {
    Write-Host "Configuring agent..."

    if (Get-Command java -ErrorAction SilentlyContinue) {
        Invoke-Expression "java -jar ${AM_HOME}\lib\agent-configurator.jar ${HOME_DIR}"
    }
    else {
        Write-Host "Error pushing configuration because java is not installed"
        exit 0
    }
}

$SERVICE_NAME="am-filebeat"
$SCHEDULED_TASK_NAME="Anypoint Monitoring Filebeat Watcher"

function Set-Recovery {
    param(
        [string]
        [Parameter(Mandatory=$true)]
        $ServiceName
    )

    sc.exe failure $ServiceName reset= 60000 actions= restart/60000
}

function Install-ServiceAgent {
    if (Get-Service $SERVICE_NAME -ErrorAction SilentlyContinue) {
        $service = Get-WmiObject -Class Win32_Service -Filter "name='$SERVICE_NAME'"
        $service.StopService()
        Start-Sleep -s 1
        $service.delete()
    }

    $FILEBEAT_DATA="${HOME_DIR}\.mule\.am\filebeat\data"
    $FILEBEAT_LOGS="${AM_HOME}\filebeat\logs"

    $workdir="${AM_HOME}\filebeat\win10"

    New-Service -name $SERVICE_NAME `
        -displayName "Anypoint Monitoring Filebeat Service" `
        -binaryPathName "`"$workdir\filebeat.exe`" -c `"$AM_HOME\config\filebeat.yml`" -path.home `"$AM_HOME`" -path.data `"$FILEBEAT_DATA`" -path.logs `"$FILEBEAT_LOGS`""
    Set-Recovery -ServiceName $SERVICE_NAME

    if (Get-ScheduledTask $SCHEDULED_TASK_NAME -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $SCHEDULED_TASK_NAME -Confirm:$false
    }

    (Get-Content -path $AM_HOME\config\am-filebeat-watcher.ps1.template).replace('$muleHome$', "$HOME_DIR") | Set-Content "$AM_HOME\bin\am-filebeat-watcher.ps1"

    $action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$AM_HOME\bin\runps.vbs`" `"$AM_HOME\bin\am-filebeat-watcher.ps1`""
    $trigger1 = New-ScheduledTaskTrigger -Daily -At 01:00
    $trigger2 = New-ScheduledTaskTrigger -Once -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration (New-TimeSpan -Hours 23 -Minutes 59) -At 01:00

    # Workaround for using both -Daily and -Repetition options.
    # Note that this workaround works only for Windows Server 2016 and above. On older Windows version, go to
    # "Properties" of the "Anypoint Monitoring Filebeat Watcher" scheduled task, and under the "Triggers" tab,
    # manually configure it to execute more frequently than "daily".
    try { $trigger1.Repetition = $trigger2.Repetition } catch {}

    $scheduledTask = New-ScheduledTask -Trigger $trigger1 -Action $action
    Register-ScheduledTask $SCHEDULED_TASK_NAME -InputObject $scheduledTask
}

Initialize-ConfigFiles
Invoke-ConfigureProxyUrl
Invoke-ConfigureAgent

$REPLY = Read-Host -Prompt "Do you want to use monitoring as a service? [y|n]"

if ($REPLY -eq 'y') {
    Install-ServiceAgent
}
