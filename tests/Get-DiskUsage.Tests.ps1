Describe 'Get-DiskUsage function' {
    BeforeAll {
        $statusPath = Join-Path $PSScriptRoot '..' 'src' 'Write-Status.ps1'
        . $statusPath
        $diskPath = Join-Path $PSScriptRoot '..' 'src' 'MonitoringTools' 'Get-DiskUsage.ps1'
        . $diskPath
    }

    It 'returns disk objects with Drive property' {
        $result = Get-DiskUsage
        $result | Should -Not -BeNullOrEmpty
        ($result | Select-Object -First 1) | Get-Member -Name Drive | Should -Not -BeNullOrEmpty
    }
}
