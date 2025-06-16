Describe 'Get-CPUUsage function' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..' 'src' 'Write-Status.ps1'
        . $modulePath
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'MonitoringTools' 'Get-CPUUsage.ps1'
        . $scriptPath
    }

    It 'returns a numeric CPU percentage' {
        $result = Get-CPUUsage
        $result | Should -BeOfType 'double'
        $result | Should -BeGreaterOrEqual 0
        $result | Should -BeLessOrEqual 100
    }

    Context 'failure conditions' {
        BeforeEach {
            Set-Item -Path variable:IsWindows -Value $false -Force
            Mock Get-Command { $null } -ParameterFilter { $Name -eq 'ps' }
        }
        AfterEach {
            Remove-Item -Path variable:IsWindows -ErrorAction SilentlyContinue
        }
        
        It 'returns null when ps command is missing' {
            $result = Get-CPUUsage
            $result | Should -Be $null
        }
    }

    Context 'ps errors' {
        BeforeEach {
            Set-Item -Path variable:IsWindows -Value $false -Force
            Mock ps { throw 'fail' }
        }
        AfterEach {
            Remove-Item -Path variable:IsWindows -ErrorAction SilentlyContinue
        }

        It 'returns null when ps throws' {
            $result = Get-CPUUsage
            $result | Should -Be $null
        }
    }

    Context 'windows scenario' {
        BeforeEach {
            Set-Item -Path variable:IsWindows -Value $true -Force
            Mock Get-Command { $true } -ParameterFilter { $Name -eq 'Get-Counter' }
            $counterObj = [pscustomobject]@{ CounterSamples = @( [pscustomobject]@{ CookedValue = 10 }, [pscustomobject]@{ CookedValue = 30 } ) }
            function Get-Counter { param($CounterPath,$SampleInterval,$MaxSamples) $counterObj }
        }
        AfterEach {
            Remove-Item -Path variable:IsWindows -ErrorAction SilentlyContinue
            Remove-Item Function:Get-Counter -ErrorAction SilentlyContinue
        }

        It 'averages Get-Counter values' {
            Get-CPUUsage | Should -Be 20
        }
    }

    Context 'ps returns no values' {
        BeforeEach {
            Set-Item -Path variable:IsWindows -Value $false -Force
            Mock Get-Command { $true } -ParameterFilter { $Name -eq 'ps' }
            Mock ps { @() }
        }
        AfterEach { Remove-Item -Path variable:IsWindows -ErrorAction SilentlyContinue }

        It 'returns null when ps outputs nothing' {
            Get-CPUUsage | Should -Be $null
        }
    }

    Context 'tools missing' {
        BeforeEach {
            Set-Item -Path variable:IsWindows -Value $true -Force
            Mock Get-Command { $null }
        }
        AfterEach {
            Remove-Item -Path variable:IsWindows -ErrorAction SilentlyContinue
        }

        It 'returns null when neither Get-Counter nor ps exists' {
            Get-CPUUsage | Should -Be $null
        }
    }
}
