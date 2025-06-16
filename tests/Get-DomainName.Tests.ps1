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

    Context 'Active Directory available' {
        BeforeEach {
            function Get-ADDomain { @{ DNSRoot = 'contoso.com' } }
        }
        AfterEach { Remove-Item Function:Get-ADDomain }

        It 'uses DNSRoot from Get-ADDomain' {
            Get-DomainName | Should -Be 'contoso.com'
        }
    }

    Context 'fallback to environment variable' {
        BeforeEach {
            function Get-ADDomain { throw 'fail' }
            $env:USERDNSDOMAIN = 'example.com'
        }
        AfterEach {
            Remove-Item Function:Get-ADDomain
            Remove-Item Env:USERDNSDOMAIN
        }

        It 'returns USERDNSDOMAIN when AD fails' {
            Get-DomainName | Should -Be 'example.com'
        }
    }
}
