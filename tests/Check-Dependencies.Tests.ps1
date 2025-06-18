Describe 'Check-Dependencies script' {
    It 'reports dependency status for all modules' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Check-Dependencies.ps1'
        $result = & $scriptPath

        $expected = 'Pester','PnP.PowerShell','ExchangeOnlineManagement','Microsoft.Graph','ActiveDirectory','Microsoft.PowerShell.SecretManagement'
        foreach ($mod in $expected) {
            ($result | Where-Object { $_.Check -eq $mod }).Count | Should -Be 1
        }
    }
}
Describe 'Check-Dependencies functions' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Check-Dependencies.ps1'
        . $scriptPath
    }

    It 'reports Installed when module exists' {
        Mock Get-Module { @{ Name = 'Pester' } }
        $result = 'Pester' | Test-RequiredModules
        $result.Status | Should -Be 'Installed'
    }

    It 'reports Missing when module does not exist' {
        Mock Get-Module { $null }
        $result = 'MissingModule' | Test-RequiredModules
        $result.Status | Should -Be 'Missing'
    }

    It 'returns Passed for PowerShell 7 or higher' {
        $original = $PSVersionTable.PSVersion
        $PSVersionTable.PSVersion = [version]'7.1'
        Mock Write-Status {}
        $result = Test-PowerShellVersion
        $result.Status | Should -Be 'Passed'
        $PSVersionTable.PSVersion = $original
    }

    It 'returns Failed for PowerShell below version 7' {
        $original = $PSVersionTable.PSVersion
        $PSVersionTable.PSVersion = [version]'6.0'
        Mock Write-Status {}
        $result = Test-PowerShellVersion
        $result.Status | Should -Be 'Failed'
        $PSVersionTable.PSVersion = $original
    }

    It 'handles threaded execution correctly' {
        $modules = 'Microsoft.PowerShell.Utility','Missing.Thread.Test'
        $result = $modules | Test-RequiredModules

        $installed = $result | Where-Object { $_.Module -eq 'Microsoft.PowerShell.Utility' }
        $missing   = $result | Where-Object { $_.Module -eq 'Missing.Thread.Test' }

        $installed.Status | Should -Be 'Installed'
        $missing.Status   | Should -Be 'Missing'

        (Get-Job).Count | Should -Be 0
    }
}
