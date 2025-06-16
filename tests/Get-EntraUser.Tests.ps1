Describe 'Get-EntraUser function' {
    BeforeEach {
        $corePath = Join-Path $PSScriptRoot '..' 'src'
        Remove-Item function:Get-EntraAccessToken -ErrorAction Ignore
        Remove-Item function:Get-EntraUser -ErrorAction Ignore
        . (Join-Path $corePath 'Write-Status.ps1')
        . (Join-Path $corePath 'ZtCore' 'ZtEntity.ps1')
        . (Join-Path $corePath 'EntraID' 'Get-EntraAccessToken.ps1')
        . (Join-Path $corePath 'EntraID' 'Get-EntraUser.ps1')
        Mock Get-EntraAccessToken { 'token' }
        $response = [pscustomobject]@{
            id = '1'
            displayName = 'User One'
            userPrincipalName = 'user@contoso.com'
        }
        Mock Invoke-RestMethod { $response }
    }

    It 'returns a ZtEntity with user details' {
        $entity = Get-EntraUser -UserPrincipalName 'user@contoso.com' -TenantId 't' -ClientId 'c'
        $entity.Source | Should -Be 'EntraID'
        $entity.ObjectType | Should -Be 'User'
        $entity.Properties.DisplayName | Should -Be 'User One'
        $entity.Identifier | Should -Be '1'
    }

    It 'retrieves an access token' {
        Get-EntraUser -UserPrincipalName 'user@contoso.com' -TenantId 't' -ClientId 'c'
        Assert-MockCalled -CommandName Get-EntraAccessToken -Times 1
    }

    It 'calls Graph users endpoint' {
        Get-EntraUser -UserPrincipalName 'user@contoso.com' -TenantId 't' -ClientId 'c'
        Assert-MockCalled -CommandName Invoke-RestMethod -ParameterFilter { $Uri -match '/users/' } -Times 1
    }
}
