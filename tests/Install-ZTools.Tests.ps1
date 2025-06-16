Describe 'Install-ZTools' {
    It 'imports Write-Status function' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Install-ZTools.ps1'
        & $scriptPath | Out-Null
        Get-Command -Name Write-Status -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }
}

Describe 'Install-ZTools configuration script handling' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Install-ZTools.ps1'
    }
    It 'does not throw when configuration script missing' {
        { . $scriptPath -ConfigScript (Join-Path $TestDrive 'missing.ps1') } | Should -Not -Throw
    }
}

