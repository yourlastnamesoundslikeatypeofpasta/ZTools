<#
.SYNOPSIS
Checks the PowerShell version and required modules.

.DESCRIPTION
`Check-Dependencies.ps1` loads `Write-Status.ps1` and verifies that the
current session is running PowerShell 7 or later. It then checks for the
presence of several required modules including `Pester`, `PnP.PowerShell`,
`ExchangeOnlineManagement`, `Microsoft.Graph` and `ActiveDirectory`. Status
messages are written for each check so missing modules or an insufficient
PowerShell version are clearly reported.

.EXAMPLE
./src/Check-Dependencies.ps1
Runs the dependency checks in the current PowerShell session and displays
the results using `Write-Status`.
#>
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
    begin {
        $modulesToCheck = @()
    }
    process {
        $modulesToCheck += $Module
    }
    end {
        $jobs = foreach ($mod in $modulesToCheck) {
            Start-ThreadJob -ScriptBlock {
                param($m)
                try {
                    if (Get-Module -ListAvailable -Name $m) {
                        [PSCustomObject]@{
                            Check   = $m
                            Module  = $m
                            Status  = "Installed"
                            Message = "Module '$m' is available."
                        }
                    } else {
                        [PSCustomObject]@{
                            Check   = $m
                            Module  = $m
                            Status  = "Missing"
                            Message = "Module '$m' is not available."
                        }
                    }
                } catch {
                    [PSCustomObject]@{
                        Check   = $m
                        Module  = $m
                        Status  = "Error"
                        Message = $_.Exception.Message
                    }
                }
            } -ArgumentList $mod
        }

        Wait-Job -Job $jobs | Out-Null
        $results = foreach ($job in $jobs) {
            $res = Receive-Job -Job $job
            Remove-Job -Job $job
            $res
        }

        foreach ($r in $results) {
            switch ($r.Status) {
                'Installed' { Write-Status -Level SUCCESS -Message "Module '$($r.Module)' is installed." }
                'Missing'   { Write-Status -Level WARN -Message "Required module '$($r.Module)' is missing." }
                'Error'     { Write-Status -Level ERROR -Message "Failed to check module '$($r.Module)'. $($r.Message)" }
            }

            $r
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
