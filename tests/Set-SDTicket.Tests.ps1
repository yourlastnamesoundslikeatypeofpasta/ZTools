Describe 'Set-SDTicket function' {
    BeforeAll {
        $root = Join-Path $PSScriptRoot '..' 'src'
    }

    BeforeEach {
        Remove-Item function:Set-SDTicket -ErrorAction Ignore
        Remove-Item function:Set-SDConfig -ErrorAction Ignore
        Remove-Item function:New-SDSession -ErrorAction Ignore
        . (Join-Path $root 'Write-Status.ps1')
        . (Join-Path $root 'ZtCore' 'ZtEntity.ps1')
        . (Join-Path $root 'SolarWindsSD' 'Invoke-SDRequest.ps1')
        . (Join-Path $root 'SolarWindsSD' 'New-SDSession.ps1')
        . (Join-Path $root 'SolarWindsSD' 'Set-SDConfig.ps1')
        . (Join-Path $root 'SolarWindsSD' 'Set-SDTicket.ps1')
        Mock Invoke-RestMethod { @{ success = $true } }
        function Set-Secret {}
        function Get-Secret {}
        function Get-SecretInfo {}
        function Import-Module {}
        Mock Set-Secret {}
        Mock Import-Module {}
        Mock Get-SecretInfo { $true }
        Mock Get-Secret {
            $value = if ($Name -match 'ApiToken') { 'token' } else { 'https://api.samanage.com' }
            [pscredential]::new('user', (ConvertTo-SecureString $value -AsPlainText -Force))
        }
        Set-SDConfig -BaseUrl 'https://api.samanage.com' -ApiToken 'token'
        New-SDSession
    }

    It 'throws when updating more than five tickets without Force' {
        { Set-SDTicket -Id 1,2,3,4,5,6 -Properties @{ state = 'Open' } } | Should -Throw
    }

    It 'does not call API in WhatIf mode' {
        Set-SDTicket -Id 1 -Properties @{ state = 'Closed' } -WhatIf
        Assert-MockCalled Invoke-RestMethod -Times 0
    }

    It 'returns an object for each updated ticket' {
        $result = Set-SDTicket -Id 2 -Properties @{ state = 'Resolved' } -Force -Confirm:$false
        $result.Source | Should -Be 'SolarWindsSD'
        $result.ObjectType | Should -Be 'Ticket'
        $result.Identifier | Should -Be 2
        $result.Properties.Updated | Should -Be $true
    }
}
