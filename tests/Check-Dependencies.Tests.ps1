Describe 'Check-Dependencies script' {
    It 'succeeds when dependencies are satisfied' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'scripts' 'Check-Dependencies.ps1'
        $result = pwsh -NoProfile -File $scriptPath 2>&1
        $exitCode = $LASTEXITCODE
        $exitCode | Should -Be 0
        ($result -join "`n") | Should -Match 'All dependencies are satisfied'
    }
}
