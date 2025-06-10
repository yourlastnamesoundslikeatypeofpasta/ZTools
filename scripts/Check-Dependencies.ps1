<##
.SYNOPSIS
Checks for required PowerShell modules and PowerShell version.
.DESCRIPTION
Ensures that all required modules are installed and that PowerShell 7 or higher is available.
Outputs status messages using the Write-Status function.
#>

param()

# Dot source the Write-Status function from the src directory
$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$writeStatusPath = Join-Path -Path $repoRoot -ChildPath 'src/Write-Status.ps1'
try {
    . $writeStatusPath
} catch {
    Write-Error "Failed to load Write-Status from $writeStatusPath"
    exit 1
}

$requiredModules = @('Pester')
$missingModules  = @()

try {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Status -Level ERROR -Message 'PowerShell 7 or higher is required.'
        exit 1
    } else {
        Write-Status -Level SUCCESS -Message "PowerShell version $($PSVersionTable.PSVersion) detected."
    }
} catch {
    Write-Status -Level ERROR -Message $_.Exception.Message
    exit 1
}

foreach ($module in $requiredModules) {
    try {
        if (Get-Module -ListAvailable -Name $module) {
            Write-Status -Level SUCCESS -Message "Module '$module' is installed."
        } else {
            Write-Status -Level ERROR -Message "Required module '$module' is missing."
            $missingModules += $module
        }
    } catch {
        Write-Status -Level ERROR -Message "Failed to check module '$module'. $_"
        exit 1
    }
}

if ($missingModules.Count -gt 0) {
    $list = $missingModules -join ', '
    Write-Status -Level ERROR -Message "Missing modules: $list"
    exit 1
}

Write-Status -Level SUCCESS -Message 'All dependencies are satisfied.'

