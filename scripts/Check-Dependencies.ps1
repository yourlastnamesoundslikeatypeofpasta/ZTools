function Test-WriteStatusModulePath {
    [CmdletBinding()]
    param()
    process {
        $writeStatusPath = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '..') -ChildPath 'src/Write-Status.ps1'
        try {
            $resolvedPath = Resolve-Path -Path $writeStatusPath -ErrorAction Stop
            Write-Output $resolvedPath
        } catch {
            Write-Error "Failed to resolve Write-Status path at $writeStatusPath"
            throw
        }
    }
}


function Test-PowerShellVersion {
    [CmdletBinding()]
    param()
    process {
        try {
            if ($PSVersionTable.PSVersion.Major -lt 7) {
                Write-Status -Level ERROR -Message 'PowerShell 7 or higher is required.'
                return [PSCustomObject]@{
                    Check   = "PowerShell Version"
                    Status  = "Failed"
                    Message = "Version $($PSVersionTable.PSVersion) is below required version 7."
                }
            } else {
                Write-Status -Level SUCCESS -Message "PowerShell version $($PSVersionTable.PSVersion) detected."
                return [PSCustomObject]@{
                    Check   = "PowerShell Version"
                    Status  = "Passed"
                    Message = "Version $($PSVersionTable.PSVersion) meets requirement."
                }
            }
        } catch {
            Write-Status -Level ERROR -Message $_.Exception.Message
            throw
        }
    }
}

function Test-RequiredModules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$Module
    )
    process {
        foreach ($mod in $Module) {
            try {
                if (Get-Module -ListAvailable -Name $mod) {
                    Write-Status -Level SUCCESS -Message "Module '$mod' is installed."
                    [PSCustomObject]@{
                        Check   = $mod
                        Module  = $mod
                        Status  = "Installed"
                        Message = "Module '$mod' is available."
                    }
                } else {
                    Write-Status -Level WARN -Message "Required module '$mod' is missing."
                    [PSCustomObject]@{
                        Check   = $mod
                        Module  = $mod
                        Status  = "Missing"
                        Message = "Module '$mod' is not available."
                    }
                }
            } catch {
                Write-Status -Level ERROR -Message "Failed to check module '$mod'. $_"
                [PSCustomObject]@{
                    Check   = $mod
                    Module  = $mod
                    Status  = "Error"
                    Message = $_.Exception.Message
                }
            }
        }
    }
}

function Test-DependencyState {
    [CmdletBinding()]
    param()
    process {
        $result = @()

        $versionCheck = Test-PowerShellVersion
        $result += $versionCheck

        $requiredModules = @(
            'Pester',
            'PnP.PowerShell',
            'ExchangeOnlineManagement',
            'Microsoft.Graph',
            'ActiveDirectory'
        )
        $moduleResults = $requiredModules | Test-RequiredModules
        $result += $moduleResults

        $missing = $moduleResults | Where-Object { $_.Status -ne "Installed" }

        if ($missing) {
            Write-Status -Level WARN -Message ("Missing modules: " + ($missing.Module -join ', '))
        } else {
            Write-Status -Level SUCCESS -Message 'All dependencies are satisfied.'
        }

        return $result
    }
}

# Entry point
$writeStatusPath = Test-WriteStatusModulePath
. $writeStatusPath
Test-DependencyState
