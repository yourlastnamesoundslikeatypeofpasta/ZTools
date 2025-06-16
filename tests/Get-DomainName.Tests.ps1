Describe 'Get-DomainName function' {
    BeforeAll {
        $statusPath = Join-Path $PSScriptRoot '..' 'src' 'Write-Status.ps1'
        . $statusPath
        $domPath = Join-Path $PSScriptRoot '..' 'src' 'MonitoringTools' 'Get-DomainName.ps1'
        . $domPath
    }

    It 'returns a string or null' {
        $result = Get-DomainName
        ($result -eq $null -or $result -is [string]) | Should -BeTrue
    }
}
