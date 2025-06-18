Describe 'ZTools module loader' {
    It 'imports functions from src' {
        Import-Module (Join-Path $PSScriptRoot '..' 'src' 'ZTools' 'ZTools.psm1') -Force
        Get-Command Get-CPUUsage -Module ZTools | Should -Not -BeNullOrEmpty
        Get-Command Set-ComputerIPAddress -Module ZTools | Should -Not -BeNullOrEmpty
    }
}
