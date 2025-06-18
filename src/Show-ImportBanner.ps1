<#
.SYNOPSIS
Displays the ZTools import banner.
.DESCRIPTION
Shows an ASCII art banner when the module is imported.
#>
function Show-ImportBanner {
    [CmdletBinding()]
    param()
    $banner = @'
 _________         _      _                     _          _
|_  /_   _|__  ___| |___ (_)_ __  _ __  ___ _ _| |_ ___ __| |
 / /  | |/ _ \/ _ \ (_-< | | '  \| '_ \/ _ \ '_|  _/ -_) _` |
/___| |_|\___/\___/_/__/ |_|_|_|_| .__/\___/_|  \__\___\__,_|
                                 |_|
'@
    Write-Host $banner -ForegroundColor Green
    return $banner
}

# Entry point executed on import
Show-ImportBanner | Out-Null
