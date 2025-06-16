Describe 'Export-ProductKey function' {
    BeforeAll {
        $corePath = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $corePath 'Write-Status.ps1')
        . (Join-Path $corePath 'SupportTools' 'Export-ProductKey.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
        Mock Start-Transcript {}
        Mock Stop-Transcript {}
        function Get-CimInstance {}
        Mock Set-Content {}
        Mock Get-CimInstance { [pscustomobject]@{ OA3xOriginalProductKey = 'ABCDE-12345' } }
    }

    It 'writes product key to specified path and returns key' {
        $path = Join-Path $TestDrive 'key.txt'
        $result = Export-ProductKey -OutputPath $path
        Assert-MockCalled -CommandName Set-Content -Times 1 -ParameterFilter { $Path -eq $path -and $Value -eq 'ABCDE-12345' }
        Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'SUCCESS' }
        $result.ProductKey | Should -Be 'ABCDE-12345'
    }

    It 'logs warning when product key not found' {
        Mock Get-CimInstance { $null }
        $path = Join-Path $TestDrive 'missing.txt'
        Export-ProductKey -OutputPath $path
        Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'WARN' } -Times 1
        Assert-MockCalled -CommandName Set-Content -Times 0
    }

    It 'does not write file when WhatIf is used' {
        $path = Join-Path $TestDrive 'whatif.txt'
        Export-ProductKey -OutputPath $path -WhatIf
        Assert-MockCalled -CommandName Set-Content -Times 0
    }
}
