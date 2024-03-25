#!/usr/bin/pwsh
param(
  [Alias('a')][string] $ACTION,
  [Alias('h')][switch] $SHOW_HELP,
  [Alias('m')][string] $HOME_DIR=''
)

# Show help
function show_help {
  Write-Host "DESCRIPTION: Run Anypoint Monitoring FileBeat"
  Write-Host "Usage: $($MyInvocation.ScriptName) [options]"
  Write-Host ""
  Write-Host "options:"
  Write-Host "-h          show help and exit"
  Write-Host "-m [DIR]    set home directory - defaults to MULE_HOME"
  Write-Host "-a [action] action to perform:"
  Write-Host "    start   - Start filebeat"
  Write-Host "    stop    - Stop filebeat"
  Write-Host "    restart - Restart filebeat"
  Write-Host ""
}

if ($SHOW_HELP) {
  show_help
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

$SERVICE_NAME="am-filebeat"
$SERVICE_DESCRIPTION="Anypoint Monitoring Filebeat Service"

$FILEBEAT_DATA="${HOME_DIR}\.mule\.am\filebeat\data"

# Start and enable the service on boot
function filebeat_start {
  Write-Host Starting and enabling $SERVICE_DESCRIPTION
  Set-Service -Name $SERVICE_NAME -StartupType Automatic
  Start-Service -Name $SERVICE_NAME
}

# Stop and disable the service on boot
function filebeat_stop {
  Write-Host Stopping and disabling $SERVICE_DESCRIPTION
  Stop-Service -Name $SERVICE_NAME
  Set-Service -Name $SERVICE_NAME -StartupType Disabled
}

# Restart function - Stops and starts the service
function filebeat_restart {
  Write-Host Restarting $SERVICE_DESCRIPTION
  Restart-Service -Name $SERVICE_NAME
}

# Restart with recovery - If the service fails to start, clear filebeat registry and retry
function filebeat_restart_with_recovery {
  Write-Host Restarting $SERVICE_DESCRIPTION
  Restart-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
  sleep 5
  if (! (ps filebeat -ErrorAction SilentlyContinue)) {
    if (Test-Path $FILEBEAT_DATA\registry.bak -PathType Leaf) {
      Write-Host 'Restoring filebeat registry from backup...'
      Move-Item -Path $FILEBEAT_DATA\registry.bak -Destination $FILEBEAT_DATA\registry -Force -ErrorAction SilentlyContinue
      Restart-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue
      sleep 5
      if (! (ps filebeat -ErrorAction SilentlyContinue)) {
        Write-Host 'Clearing invalid filebeat registry...'
        Remove-Item $FILEBEAT_DATA\registry -Force -ErrorAction SilentlyContinue
        Restart-Service -Name $SERVICE_NAME
      }
    }
    else {
      Write-Host 'Clearing invalid filebeat registry...'
      Remove-Item $FILEBEAT_DATA\registry -Force -ErrorAction SilentlyContinue
      Restart-Service -Name $SERVICE_NAME
    }
  }
}

switch($ACTION) {
  'start'   { filebeat_start }
  'stop'    { filebeat_stop }
  'restart' { filebeat_restart }
  'restart_with_recovery' { filebeat_restart_with_recovery }
  default   { show_help }
}
