Describe 'Get-SystemHealth function' {
    BeforeAll {
        $statusPath = Join-Path $PSScriptRoot '..' 'src' 'Write-Status.ps1'
        . $statusPath
        $cpuPath = Join-Path $PSScriptRoot '..' 'src' 'MonitoringTools' 'Get-CPUUsage.ps1'
        . $cpuPath
        $ramPath = Join-Path $PSScriptRoot '..' 'src' 'MonitoringTools' 'Get-RAMUsage.ps1'
        . $ramPath
        $diskPath = Join-Path $PSScriptRoot '..' 'src' 'MonitoringTools' 'Get-DiskUsage.ps1'
        . $diskPath
        $domainPath = Join-Path $PSScriptRoot '..' 'src' 'MonitoringTools' 'Get-DomainName.ps1'
        . $domainPath
        $healthPath = Join-Path $PSScriptRoot '..' 'src' 'MonitoringTools' 'Get-SystemHealth.ps1'
        . $healthPath
    }

    It 'returns an object with CPUPercent and DomainName' {
        $result = Get-SystemHealth
        $result | Should -Not -BeNullOrEmpty
        $result | Get-Member -Name CPUPercent | Should -Not -BeNullOrEmpty
        $result | Get-Member -Name DomainName | Should -Not -BeNullOrEmpty
    }
}
