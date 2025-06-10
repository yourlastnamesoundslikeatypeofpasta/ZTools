<#
.SYNOPSIS
Outputs a stylized status message.
.DESCRIPTION
Provides a timestamped, colorized output with standardized prefixes for
various logging levels. This is intended to replace direct calls to
Write-Host or Write-Error in other scripts.
.PARAMETER Level
The logging level to use. Supported values are INFO, OK, WARN,
FAIL, EXEC, DONE, DEBUG.
.PARAMETER Message
The message to display.
.EXAMPLE
Write-Status -Level INFO -Message "Starting deployment"
#>
function Write-Status {
    param (
        [Parameter(Mandatory)]
        [ValidateSet("INFO", "OK", "WARN", "FAIL", "EXEC", "DONE", "DEBUG")]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $timestamp = (Get-Date -Format "HH:mm:ss")
    $prefix = switch ($Level) {
        "INFO"  { "[*]" }
        "OK"    { "[+]" }
        "WARN"  { "[!]" }
        "FAIL"  { "[-]" }
        "EXEC"  { "[>]" }
        "DONE"  { "[✓]" }
        "DEBUG" { "[~]" }
        default { "[*]" }
    }

    $color = switch ($Level) {
        "INFO"  { "Cyan" }
        "OK"    { "Green" }
        "WARN"  { "Yellow" }
        "FAIL"  { "Red" }
        "EXEC"  { "White" }
        "DONE"  { "Gray" }
        "DEBUG" { "DarkGray" }
        default { "White" }
    }

    $line = "$timestamp $prefix $Message"

    if ($Level -eq "FAIL") {
        Write-Error $line
    } else {
        Write-Host $line -ForegroundColor $color
    }
}
