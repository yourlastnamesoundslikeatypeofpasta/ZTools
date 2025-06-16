Describe 'Check-Dependencies script' {
    It 'succeeds when dependencies are satisfied' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'scripts' 'Check-Dependencies.ps1'
        $json = pwsh -NoProfile -Command "& '$scriptPath' | ConvertTo-Json" 2>&1
        $exitCode = $LASTEXITCODE
        $exitCode | Should -Be 0
        $result = $json | ConvertFrom-Json
        ($result | Where-Object { $_.Status -in @('Missing','Error') }).Count | Should -Be 0
    }
}
