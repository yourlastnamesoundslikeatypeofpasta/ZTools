<##
.SYNOPSIS
Writes a formatted status message and logs it to a file.
.DESCRIPTION
Outputs colored status messages for different log levels and appends them to a log file under the repository's /logs folder. The log file path is stored in the script-scoped variable `$script:StatusLogFile`.
.PARAMETER Level
The level of the message: INFO, WARN, ERROR or SUCCESS.
.PARAMETER Message
The message text to display and log.
#>

if (-not $script:StatusLogFile) {
    $repoRoot = Split-Path -Path $PSScriptRoot -Parent
    $logDir   = Join-Path -Path $repoRoot -ChildPath 'logs'
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $script:StatusLogFile = Join-Path -Path $logDir -ChildPath "$timestamp.log"
}

function Write-Status {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('INFO','WARN','ERROR','SUCCESS')]
        [string]$Level,
        [Parameter(Mandatory)]
        [string]$Message
    )

    switch ($Level) {
        'INFO'    { Write-Host $Message -ForegroundColor Cyan }
        'WARN'    { Write-Warning $Message }
        'ERROR'   { Write-Error $Message }
        'SUCCESS' { Write-Host $Message -ForegroundColor Green }
    }

    $time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $symbol = switch ($Level) {
        'INFO'    { '-' }
        'WARN'    { '!' }
        'ERROR'   { 'X' }
        'SUCCESS' { '+' }
    }
    $entry = "$time [$symbol] $Message"
    Add-Content -Path $script:StatusLogFile -Value $entry -Encoding utf8
}
