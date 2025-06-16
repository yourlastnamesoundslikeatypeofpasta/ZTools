<#
.SYNOPSIS
Writes a formatted status message and logs it to a file.

.DESCRIPTION
`Write-Status` routes log messages through the appropriate PowerShell cmdlets
(`Write-Verbose`, `Write-Debug`, `Write-Warning`, `Write-Error`) so standard
preference variables control what is displayed. Messages are also appended to a
log file. A default log file is created under the repository's `logs` folder but
the path can be overridden via the `LogFile` parameter.

.PARAMETER Level
The level of the message: INFO, WARN, ERROR, SUCCESS or DEBUG.

.PARAMETER Message
The message text to display and log. Accepts pipeline input.

.PARAMETER LogFile
Path to the log file. Defaults to a timestamped log under the repository's
`logs` directory.

.PARAMETER Fast
Skips colored console output for faster logging.

.EXAMPLE
Write-Status -Level INFO -Message 'Build started'

.EXAMPLE
'Completed' | Write-Status -Level SUCCESS -LogFile 'C:\temp\run.log'

.EXAMPLE
Write-Status -Level ERROR -Message 'Failed' -Fast

This function maps the provided level to `Write-Verbose`, `Write-Debug`,
`Write-Warning` and `Write-Error` internally so `$VerbosePreference` and
`$DebugPreference` affect console output.
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

function global:Write-Status {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('INFO','WARN','ERROR','SUCCESS','DEBUG')]
        [string]$Level,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Message,

        [string]$LogFile = $script:StatusLogFile,

        [switch]$Fast
    )

    process {
        if ($LogFile -ne $script:StatusLogFile) {
            $script:StatusLogFile = $LogFile
        }

        $time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $symbol = switch ($Level) {
            'INFO'    { '-' }
            'WARN'    { '!' }
            'ERROR'   { 'X' }
            'SUCCESS' { '+' }
            'DEBUG'   { '*' }
        }
        $entry = "$time [$symbol] $Message"
        Add-Content -Path $script:StatusLogFile -Value $entry -Encoding utf8

        if ($Fast) {
            switch ($Level) {
                'INFO'    { Write-Verbose $Message }
                'DEBUG'   { Write-Debug   $Message }
                'WARN'    { Write-Warning $Message }
                'ERROR'   { Write-Error   $Message }
                'SUCCESS' { Write-Verbose $Message }
            }
        }
        else {
            switch ($Level) {
                'INFO' {
                    if ($VerbosePreference -ne 'SilentlyContinue') {
                        Write-Host $Message -ForegroundColor Cyan
                    }
                    Write-Verbose $Message
                }
                'DEBUG'   { Write-Debug   $Message }
                'WARN'    { Write-Warning $Message }
                'ERROR'   { Write-Error   $Message }
                'SUCCESS' {
                    if ($VerbosePreference -ne 'SilentlyContinue') {
                        Write-Host $Message -ForegroundColor Green
                    }
                    Write-Verbose $Message
                }
            }
        }
    }
}
