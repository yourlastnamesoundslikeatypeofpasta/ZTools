<#
.SYNOPSIS
Installs the ZTools environment by importing modules.
.DESCRIPTION
Loads every *.ps1 file under the repository's src directory so their functions are available in the current session. Optionally a configuration script can be run after modules are imported.
.PARAMETER ConfigScript
Optional path to an additional configuration script to run once the modules are loaded.
.EXAMPLE
Install-ZTools
.EXAMPLE
Install-ZTools -ConfigScript './scripts/Configure-SharePoint.ps1'
#>
function Install-ZTools {
    [CmdletBinding()]
    param(
        [string]$ConfigScript
    )

    $repoRoot = Split-Path -Path $PSScriptRoot -Parent
    $srcPath  = Join-Path -Path $repoRoot -ChildPath 'src'

    $writeStatusPath = Join-Path -Path $srcPath -ChildPath 'Write-Status.ps1'
    . $writeStatusPath

    $moduleFiles = Get-ChildItem -Path $srcPath -Recurse -Filter '*.ps1' |
                   Where-Object { $_.FullName -ne $PSCommandPath -and $_.FullName -ne $writeStatusPath }

    foreach ($file in $moduleFiles) {
        Write-Status -Level INFO -Message "Importing $(Split-Path -Leaf $file.FullName)" -Fast
        . $file.FullName
    }

    if ($PSBoundParameters.ContainsKey('ConfigScript')) {
        if (Test-Path $ConfigScript) {
            Write-Status -Level INFO -Message "Running configuration script $ConfigScript" -Fast
            . $ConfigScript
        }
        else {
            Write-Status -Level WARN -Message "Configuration script '$ConfigScript' not found." -Fast
        }
    }
}

# Entry point
Install-ZTools @PSBoundParameters
