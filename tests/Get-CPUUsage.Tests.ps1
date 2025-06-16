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
}
