Describe 'Show-ImportBanner' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Show-ImportBanner.ps1'
        . $scriptPath
    }
    It 'returns banner string' {
        $result = Show-ImportBanner
        $result | Should -BeOfType String
    }
}
