Describe 'Check-Dependencies script' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '..' 'scripts' 'Check-Dependencies.ps1'
        . $scriptPath > $null
    }

    Context 'Functional tests' {
        It 'reports dependency status for all modules' {
            $scriptPath = Join-Path $PSScriptRoot '..' 'scripts' 'Check-Dependencies.ps1'
            $mods = 'Pester','PnP.PowerShell','ExchangeOnlineManagement','Microsoft.Graph','ActiveDirectory'
            Mock Get-Module { @{Name=$Name} }
            Mock Write-Status {}
            $result = & $scriptPath
            foreach ($mod in $mods) {
                ($result | Where-Object { $_.Check -eq $mod }).Status | Should -Be 'Installed'
            }
        }

        It 'resolves Write-Status path' {
            $expected = 'resolved.ps1'
            Mock Resolve-Path { $expected } -ParameterFilter { $Path -like '*Write-Status.ps1' }
            Test-WriteStatusModulePath | Should -Be $expected
        }

        It 'passes PowerShell version check when version is 7 or higher' {
            Mock Write-Status {}
            $PSVersionTable.PSVersion = [version]'7.2'
            (Test-PowerShellVersion).Status | Should -Be 'Passed'
        }

        It 'fails PowerShell version check when version is below 7' {
            Mock Write-Status {}
            $PSVersionTable.PSVersion = [version]'5.1'
            (Test-PowerShellVersion).Status | Should -Be 'Failed'
        }

        It 'detects installed modules' {
            Mock Get-Module { @{Name='InstalledMod'} } -ParameterFilter { $Name -eq 'InstalledMod' -and $ListAvailable }
            Mock Write-Status {}
            (Test-RequiredModules -Module 'InstalledMod').Status | Should -Be 'Installed'
        }

        It 'detects missing modules' {
            Mock Get-Module { $null } -ParameterFilter { $Name -eq 'MissingMod' -and $ListAvailable }
            Mock Write-Status {}
            (Test-RequiredModules -Module 'MissingMod').Status | Should -Be 'Missing'
        }

        It 'handles module check errors' {
            Mock Get-Module { throw 'fail' } -ParameterFilter { $Name -eq 'BrokenMod' -and $ListAvailable }
            Mock Write-Status {}
            (Test-RequiredModules -Module 'BrokenMod').Status | Should -Be 'Error'
        }

        It 'accepts pipeline input' {
            Mock Get-Module { @{Name=$Name} } -ParameterFilter { $ListAvailable }
            Mock Write-Status {}
            $result = 'One','Two' | Test-RequiredModules
            $result.Count | Should -Be 2
        }

        It 'logs success when all dependencies are installed' {
            Mock Get-Module { @{Name=$Name} }
            Mock Write-Status {} -ParameterFilter { $Level -eq 'SUCCESS' } -Verifiable
            $PSVersionTable.PSVersion = [version]'7.1'
            Test-DependencyState | Out-Null
            Assert-MockCalled Write-Status -ParameterFilter { $Level -eq 'SUCCESS' } -Times 1
        }

        It 'logs warning when modules are missing' {
            Mock Get-Module { if ($Name -eq 'PnP.PowerShell') { $null } else { @{Name=$Name} } }
            Mock Write-Status {} -ParameterFilter { $Level -eq 'WARN' } -Verifiable
            $PSVersionTable.PSVersion = [version]'7.1'
            Test-DependencyState | Out-Null
            Assert-MockCalled Write-Status -ParameterFilter { $Level -eq 'WARN' } -Times 1
        }
    }

    Context 'Edge case tests' {
        It 'throws when Write-Status path cannot be resolved' {
            Mock Resolve-Path { throw 'not found' }
            { Test-WriteStatusModulePath } | Should -Throw
        }

        It 'returns nothing when no modules are supplied' {
            Mock Write-Status {}
            $result = @() | Test-RequiredModules
            $result | Should -BeNullOrEmpty
        }

        It 'marks module with error status when Get-Module throws' {
            Mock Get-Module { if ($Name -eq 'Microsoft.Graph') { throw 'bad' } else { @{Name=$Name} } }
            Mock Write-Status {}
            $PSVersionTable.PSVersion = [version]'7.1'
            $result = Test-DependencyState
            ($result | Where-Object { $_.Check -eq 'Microsoft.Graph' }).Status | Should -Be 'Error'
        }
    }
}
