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
}
