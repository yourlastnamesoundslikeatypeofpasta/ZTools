Describe 'Test-IsAdministrator function' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Test-IsAdministrator.ps1'
        . $scriptPath
    }

    It 'returns a boolean value' {
        { Test-IsAdministrator } | Should -Not -Throw
        Test-IsAdministrator | Should -BeOfType 'System.Boolean'
    }
}
