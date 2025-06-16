Describe 'Configure-SharePoint script' {
    It 'imports Set-SharePointConfig function' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Configure-SharePoint.ps1'
        . $scriptPath
        Get-Command -Name Set-SharePointConfig -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }
}

Describe 'Set-SharePointConfig function' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Configure-SharePoint.ps1'
        . $scriptPath
    }

    BeforeEach {
        function New-StoredCredential {}
        function Import-Module {}
        Mock New-StoredCredential {}
        Mock Import-Module {}
    }

    It 'stores credentials when parameters are provided' {
        $sec = ConvertTo-SecureString 'pass' -AsPlainText -Force
        $cred = [pscredential]::new('user',$sec)
        Set-SharePointConfig -TenantId 'tenant' -ClientCredential $cred -UserCredential $cred
        Assert-MockCalled -CommandName New-StoredCredential -Times 3
    }

    It 'prompts for missing values' {
        $sec = ConvertTo-SecureString 'pass' -AsPlainText -Force
        $cred = [pscredential]::new('user',$sec)
        Mock Get-Credential { $cred }
        Mock Read-Host { 'tenant' }
        Set-SharePointConfig
        Assert-MockCalled -CommandName Get-Credential -Times 2
        Assert-MockCalled -CommandName Read-Host -Times 1
    }

    It 'logs error when credential storage fails' {
        $sec = ConvertTo-SecureString 'pass' -AsPlainText -Force
        $cred = [pscredential]::new('user',$sec)
        Mock New-StoredCredential { throw 'fail' }
        Mock Write-Status {}
        { Set-SharePointConfig -TenantId 'tenant' -ClientCredential $cred -UserCredential $cred } | Should -Throw
        Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' } -Times 1
    }
}

