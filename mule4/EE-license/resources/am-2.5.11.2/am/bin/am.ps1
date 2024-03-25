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
  Write-Host "    check   - Check connectivity"
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

$AM_HOME="${HOME_DIR}\am"

$FILEBEAT_DATA="${HOME_DIR}\.mule\.am\filebeat\data"
$FILEBEAT_LOGS="${AM_HOME}\filebeat\logs"

$WORKDIR="${AM_HOME}\filebeat\win10"

function do_start {
  if (! (ps filebeat -ErrorAction SilentlyContinue)) {
    Write-Host 'Starting filebeat'
    Start-Process "$WORKDIR\filebeat.exe" -WindowStyle Hidden -ArgumentList "-c `"$AM_HOME\config\filebeat.yml`" -path.home `"$AM_HOME`" -path.data `"$FILEBEAT_DATA`" -path.logs `"$FILEBEAT_LOGS`""
  } else {
    Write-Host 'Warning: filebeat already running'
  }
}

function do_stop {
  if (ps filebeat -ErrorAction SilentlyContinue) {
    Write-Host 'Stopping filebeat'
    ps filebeat -ErrorAction SilentlyContinue | Stop-Process
  } else {
    Write-Host 'Warning: filebeat not running'
  }
}

function do_restart {
  do_stop
  while (ps filebeat -ErrorAction SilentlyContinue) {
    sleep 1
  }
  do_start
}

function do_restart_with_recovery {
  do_stop
  while (ps filebeat -ErrorAction SilentlyContinue) {
    sleep 1
  }
  do_start
  sleep 5
  if (! (ps filebeat -ErrorAction SilentlyContinue)) {
    if (Test-Path $FILEBEAT_DATA\registry.bak -PathType Leaf) {
      Write-Host 'Restoring filebeat registry from backup...'
      Move-Item -Path $FILEBEAT_DATA\registry.bak -Destination $FILEBEAT_DATA\registry -Force -ErrorAction SilentlyContinue
      do_restart
      sleep 5
      if (! (ps filebeat -ErrorAction SilentlyContinue)) {
        Write-Host 'Clearing invalid filebeat registry...'
        Remove-Item $FILEBEAT_DATA\registry -Force -ErrorAction SilentlyContinue
        do_restart
      }
    }
    else {
      Write-Host 'Clearing invalid filebeat registry...'
      Remove-Item $FILEBEAT_DATA\registry -Force -ErrorAction SilentlyContinue
      do_restart
    }
  }
}

function do_check {
  Write-Host 'Checking connectivity'
  & "$WORKDIR\filebeat.exe" "test" "output" "-c" "$AM_HOME\config\filebeat.yml" "-path.home" "$AM_HOME" "-path.data" "$FILEBEAT_DATA"
}

switch($ACTION) {
  'start'   { do_start }
  'stop'    { do_stop }
  'restart' { do_restart }
  'restart_with_recovery' { do_restart_with_recovery }
  'check'   { do_check }
  default   { show_help }
}
