Describe 'Set-ComputerIPAddress function' {
    BeforeAll {
        $corePath = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $corePath 'Write-Status.ps1')
        . (Join-Path $corePath 'SupportTools' 'Set-ComputerIPAddress.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
        Mock Get-NetAdapter { [pscustomobject]@{ Name = 'Ethernet' } }
        Mock Get-NetIPConfiguration { [pscustomobject]@{ IPv4Address = $null; IPv4DefaultGateway = $null } }
        Mock Remove-NetIPAddress {}
        Mock Remove-NetRoute {}
        Mock New-NetIPAddress {}
        Mock Set-DnsClientServerAddress {}
        Mock Restart-NetAdapter {}
        Mock Clear-DnsClientCache {}
    }

    It 'configures IP when computer name matches' {
        $csv = @"
ComputerName,StaticIPAddress
$($env:COMPUTERNAME),10.0.0.5
"@ | Out-String
        $path = Join-Path $TestDrive 'match.csv'
        $csv | Set-Content -Path $path
        Set-ComputerIPAddress -CSVPath $path
        Assert-MockCalled -CommandName New-NetIPAddress -Times 1
        Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'SUCCESS' } -Times 1
    }

    It 'logs warning when no match found' {
        $csv = @"ComputerName,StaticIPAddress
Other,10.0.0.5"@
        $path = Join-Path $TestDrive 'nomatch.csv'
        $csv | Set-Content -Path $path
        Set-ComputerIPAddress -CSVPath $path
        Assert-MockCalled -CommandName New-NetIPAddress -Times 0
        Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'WARN' } -Times 1
    }

    It 'does not modify adapter in WhatIf mode' {
        $csv = @"ComputerName,StaticIPAddress
$($env:COMPUTERNAME),10.0.0.5"@
        $path = Join-Path $TestDrive 'whatif.csv'
        $csv | Set-Content -Path $path
        Set-ComputerIPAddress -CSVPath $path -WhatIf
        Assert-MockCalled -CommandName New-NetIPAddress -Times 0
    }
}
