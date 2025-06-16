Describe 'Install-ZTools' {
    It 'imports Write-Status function' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Install-ZTools.ps1'
        & $scriptPath | Out-Null
        Get-Command -Name Write-Status -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }
}
