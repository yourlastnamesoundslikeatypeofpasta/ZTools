# ZTools PowerShell module
# Loads all cmdlet functions from the src directory.

$modulePath = $MyInvocation.MyCommand.Path
$srcRoot    = Split-Path -Path $PSScriptRoot -Parent

Get-ChildItem -Path $srcRoot -Recurse -Filter '*.ps1' |
    Where-Object { $_.FullName -ne $modulePath -and $_.Name -ne 'Install-ZTools.ps1' } |
    ForEach-Object { . $_.FullName }
