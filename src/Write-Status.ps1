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
The message text to display and log. 

.PARAMETER LogFile
Path to the log file. Defaults to a timestamped log under the repository's
`logs` directory.

.PARAMETER Fast
Skips colored console output for faster logging.

.EXAMPLE
Write-Status -Level INFO -Message 'Build started'

.EXAMPLE
Write-Status -Level ERROR -Message 'Failed' -Fast

This function maps the provided level to `Write-Verbose`, `Write-Debug`,
`Write-Warning` and `Write-Error` internally so `$VerbosePreference` and
`$DebugPreference` affect console output.
#>

$repoRoot              = Split-Path -Path $PSScriptRoot -Parent
$script:LogDirectory   = Join-Path -Path $repoRoot -ChildPath 'logs'
$script:ErrorLogFile   = Join-Path -Path $script:LogDirectory -ChildPath 'error.log'
$script:StatusLogFile  = $null
$script:LogHour        = $null

function New-LogDirectory {
    <#
    .SYNOPSIS
    Ensures the log directory exists.
    .PARAMETER Path
    Directory path to create if missing.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function Write-Banner {
    <#
    .SYNOPSIS
    Writes a header similar to `Start-Transcript` at the start of a log file.
    .PARAMETER Path
    The log file to write the banner to.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $machine = $env:COMPUTERNAME
    $now     = Get-Date -Format 'MM/dd/yyyy HH:mm:ss'
    $lines   = @(
        '**********************',
        "Machine : $machine",
        "Date    : $now",
        '**********************'
    )
    Add-Content -Path $Path -Value ($lines -join [Environment]::NewLine) -Encoding utf8
}

function New-LogFile {
    <#
    .SYNOPSIS
    Creates or rotates the hourly log file.
    .PARAMETER Directory
    Directory where logs are stored.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Directory
    )

    New-LogDirectory -Path $Directory

    $hour    = Get-Date -Format 'yyyy-MM-dd_HH'
    $logPath = Join-Path -Path $Directory -ChildPath "$hour.log"

    if (-not (Test-Path $logPath)) {
        New-Item -Path $logPath -ItemType File -Force | Out-Null
        Write-Banner -Path $logPath
    }

    $script:LogHour       = $hour
    $script:StatusLogFile = $logPath
    return $logPath
}

function Write-ErrorLog {
    <#
    .SYNOPSIS
    Appends an entry to the persistent error log.
    .PARAMETER Message
    Message text to record.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [string]$Path = $script:ErrorLogFile
    )

    process {
        New-LogDirectory -Path (Split-Path -Path $Path -Parent)
        $time    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $machine = $env:COMPUTERNAME
        $entry   = "$time [$machine] $Message"
        Add-Content -Path $Path -Value $entry -Encoding utf8
    }
}

function global:Write-Status {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('INFO','WARN','ERROR','SUCCESS','DEBUG')]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message,

        [string]$LogFile = $script:StatusLogFile,

        [switch]$Fast
    )

    $currentHour = Get-Date -Format 'yyyy-MM-dd_HH'
    if ($PSBoundParameters.ContainsKey('LogFile')) {
        if ($LogFile -ne $script:StatusLogFile) {
            New-LogDirectory -Path (Split-Path -Path $LogFile -Parent)
            if (-not (Test-Path $LogFile)) {
                New-Item -Path $LogFile -ItemType File -Force | Out-Null
                Write-Banner -Path $LogFile
            }
            $script:StatusLogFile = $LogFile
            $script:LogHour       = $currentHour
        }
    } else {
        if (-not $script:StatusLogFile -or $currentHour -ne $script:LogHour) {
            New-LogFile -Directory $script:LogDirectory | Out-Null
        }
        $LogFile = $script:StatusLogFile
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
    if ($Level -eq 'ERROR') {
        Write-ErrorLog -Message $Message
    }

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
