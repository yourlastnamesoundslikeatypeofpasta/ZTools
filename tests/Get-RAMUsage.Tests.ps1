Describe 'Get-RAMUsage function' {
    BeforeAll {
        $statusPath = Join-Path $PSScriptRoot '..' 'src' 'Write-Status.ps1'
        . $statusPath
        $ramPath = Join-Path $PSScriptRoot '..' 'src' 'MonitoringTools' 'Get-RAMUsage.ps1'
        . $ramPath
    }

    It 'returns an object with PercentUsed' {
        $result = Get-RAMUsage
        $result | Should -Not -BeNullOrEmpty
        $result | Get-Member -Name PercentUsed | Should -Not -BeNullOrEmpty
    }

    Context 'meminfo missing' {
        BeforeEach {
            Mock Test-Path { $false } -ParameterFilter { $Path -eq '/proc/meminfo' }
            Mock Get-Command { $null } -ParameterFilter { $Name -eq 'Get-CimInstance' }
            Mock Get-Command { $null } -ParameterFilter { $Name -eq 'vm_stat' }
            Mock Get-Command { $null } -ParameterFilter { $Name -eq 'sysctl' }
        }

        It 'returns null when /proc/meminfo is absent' {
            Get-RAMUsage | Should -Be $null
        }
    }

    Context 'no MemAvailable entry' {
        BeforeEach {
            Mock Get-Content { @('MemTotal: 1000 kB','MemFree: 400 kB') } -ParameterFilter { $Path -eq '/proc/meminfo' }
            Mock Get-Command { $null } -ParameterFilter { $Name -eq 'Get-CimInstance' }
            Mock Get-Command { $null } -ParameterFilter { $Name -eq 'vm_stat' }
            Mock Get-Command { $null } -ParameterFilter { $Name -eq 'sysctl' }
        }

        It 'falls back to MemFree parsing' {
            $result = Get-RAMUsage
            $result.FreeMB | Should -BeGreaterThan 0.38
        }
    }
}
