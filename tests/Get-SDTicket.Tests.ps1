Describe 'Get-SDTicket function' {
    BeforeAll {
        $root = Join-Path $PSScriptRoot '..' 'src'
    }

    BeforeEach {
        Remove-Item function:Get-SDTicket -ErrorAction Ignore
        Remove-Item function:Set-SDConfig -ErrorAction Ignore
        Remove-Item function:New-SDSession -ErrorAction Ignore
        . (Join-Path $root 'Write-Status.ps1')
        . (Join-Path $root 'ZtCore' 'ZtEntity.ps1')
        . (Join-Path $root 'SolarWindsSD' 'Invoke-SDRequest.ps1')
        . (Join-Path $root 'SolarWindsSD' 'New-SDSession.ps1')
        . (Join-Path $root 'SolarWindsSD' 'Set-SDConfig.ps1')
        . (Join-Path $root 'SolarWindsSD' 'Get-SDTicket.ps1')
        Mock Invoke-RestMethod { @{ id = 1 } }
        function New-StoredCredential {}
        function Get-StoredCredential {}
        function Import-Module {}
        Mock New-StoredCredential {}
        Mock Import-Module {}
        Mock Get-StoredCredential {
            [pscustomobject]@{ Password = if ($Target -match 'ApiToken') { 'token' } else { 'https://api.samanage.com' } }
        }
        Set-SDConfig -BaseUrl 'https://api.samanage.com' -ApiToken 'token'
        New-SDSession
    }

    It 'calls REST endpoint for ticket' {
        Get-SDTicket -Id 1
        Assert-MockCalled Invoke-RestMethod -Times 1 -ParameterFilter { $Uri -eq 'https://api.samanage.com/incidents/1' -and $Method -eq 'GET' }
    }

    It 'returns a ZtEntity-like object for the ticket' {
        Mock Invoke-RestMethod { [pscustomobject]@{ id = 42; state = 'Open' } }
        $ticket = Get-SDTicket -Id 42
        $ticket.Source | Should -Be 'SolarWindsSD'
        $ticket.ObjectType | Should -Be 'Ticket'
        $ticket.Identifier | Should -Be 42
        $ticket.Properties.state | Should -Be 'Open'
    }

    It 'creates a ZtEntity-like object when starting a session' {
        $session = New-SDSession
        $session.Source | Should -Be 'SolarWindsSD'
        $session.ObjectType | Should -Be 'Session'
    }
}
