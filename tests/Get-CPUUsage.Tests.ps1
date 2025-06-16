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
            Mock Get-Command { $null } -ParameterFilter { $Name -eq 'ps' }
        }

        It 'returns null when ps command is missing' {
            $result = Get-CPUUsage
            $result | Should -Be $null
        }
    }

    Context 'ps errors' {
        BeforeEach {
            Mock ps { throw 'fail' }
        }

        It 'returns null when ps throws' {
            $result = Get-CPUUsage
            $result | Should -Be $null
        }
    }
}
