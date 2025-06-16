Describe 'Check-Dependencies script' {
    It 'reports dependency status for all modules' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'scripts' 'Check-Dependencies.ps1'
        $result = & $scriptPath

        $expected = 'Pester','PnP.PowerShell','ExchangeOnlineManagement','Microsoft.Graph','ActiveDirectory'
        foreach ($mod in $expected) {
            ($result | Where-Object { $_.Check -eq $mod }).Count | Should -Be 1
        }
    }
}
