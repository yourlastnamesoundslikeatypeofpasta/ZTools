<#
.SYNOPSIS
Checks if the current session is running with administrator privileges.

.DESCRIPTION
Returns `$true` when the current Windows user is a member of the Administrators group. On non-Windows platforms the check always returns `$false`.

.EXAMPLE
if (Test-IsAdministrator) {
    # perform elevated task
}
#>
function global:Test-IsAdministrator {
    [CmdletBinding()]
    param()
    process {
        if (-not $IsWindows) { return $false }
        $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]$identity
        $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
}
