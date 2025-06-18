Describe 'Set-SDConfig script' {
    It 'imports Set-SDConfig function' {
        $path = Join-Path $PSScriptRoot '..' 'src' 'SolarWindsSD' 'Set-SDConfig.ps1'
        . $path
        Get-Command -Name Set-SDConfig -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }
}

Describe 'Set-SDConfig function' {
    BeforeAll {
        $root = Join-Path $PSScriptRoot '..' 'src'
    }

    BeforeEach {
        Remove-Item function:Set-SDConfig -ErrorAction Ignore
        . (Join-Path $root 'ZtCore' 'ZtEntity.ps1')
        . (Join-Path $root 'SolarWindsSD' 'Set-SDConfig.ps1')
        function New-StoredCredential {}
        function Import-Module {}
        Mock New-StoredCredential {}
        Mock Import-Module {}
    }

    It 'stores values when parameters are provided' {
        Set-SDConfig -BaseUrl 'https://api.samanage.com' -ApiToken 'token'
        Assert-MockCalled -CommandName New-StoredCredential -Times 2
    }

    It 'prompts for missing values' {
        Mock Read-Host { 'value' }
        Set-SDConfig -ApiToken 'token'
        Assert-MockCalled -CommandName Read-Host -Times 1
    }

    It 'logs error when storage fails' {
        Mock New-StoredCredential { throw 'fail' }
        Mock Write-Status {}
        { Set-SDConfig -BaseUrl 'url' -ApiToken 'token' } | Should -Throw
        Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' } -Times 1
    }

    It 'returns an object with base url info' {
        $entity = Set-SDConfig -BaseUrl 'https://api.samanage.com' -ApiToken 'token'
        $entity.Source | Should -Be 'SolarWindsSD'
        $entity.ObjectType | Should -Be 'Config'
        $entity.Properties.BaseUrl | Should -Be 'https://api.samanage.com'
    }
}
