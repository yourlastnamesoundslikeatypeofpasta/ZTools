Describe 'Set-ComputerIPAddress function' {
    BeforeAll {
        $corePath = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $corePath 'Write-Status.ps1')
        . (Join-Path $corePath 'Test-IsAdministrator.ps1')
        . (Join-Path $corePath 'SupportTools' 'Set-ComputerIPAddress.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
        Mock Test-IsAdministrator { $true }
        function Get-NetAdapter {}
        function Get-NetIPConfiguration {}
        function Remove-NetIPAddress {}
        function Remove-NetRoute {}
        function New-NetIPAddress {}
        function Set-DnsClientServerAddress {}
        function Restart-NetAdapter {}
        function Clear-DnsClientCache {}

        Mock Get-NetAdapter { [pscustomobject]@{ Name = 'Ethernet' } }
        Mock Get-NetIPConfiguration { [pscustomobject]@{ IPv4Address = $null; IPv4DefaultGateway = $null } }
        Mock Remove-NetIPAddress {}
        Mock Remove-NetRoute {}
        Mock New-NetIPAddress {}
        Mock Set-DnsClientServerAddress {}
        Mock Restart-NetAdapter {}
        Mock Clear-DnsClientCache {}
    }

    It 'configures IP with provided address' {
        Set-ComputerIPAddress -IPAddress '10.0.0.5' -DefaultGateway '10.0.0.1'
        Assert-MockCalled -CommandName New-NetIPAddress -Times 1
        Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'SUCCESS' } -Times 1
    }

    It 'logs error when adapter is missing' {
        Mock Get-NetAdapter { $null }
        Set-ComputerIPAddress -IPAddress '10.0.0.5'
        Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' } -Times 1
    }

    It 'does not modify adapter in WhatIf mode' {
        Set-ComputerIPAddress -IPAddress '10.0.0.5' -WhatIf
        Assert-MockCalled -CommandName New-NetIPAddress -Times 0
    }

    It 'accepts pipeline input' {
        $obj = [pscustomobject]@{ IPAddress = '10.0.0.6'; DefaultGateway = '10.0.0.1' }
        $obj | Set-ComputerIPAddress
        Assert-MockCalled -CommandName New-NetIPAddress -Times 1
    }
}
