Describe 'Write-Status' {
    BeforeAll {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Write-Status.ps1'
        . $scriptPath
    }

    BeforeEach {
        Set-WriteStatusConfig -LogDirectory (Join-Path $TestDrive 'logs') -ErrorLogFile (Join-Path $TestDrive 'logs' 'error.log')
        $script:StatusLogFile = $null
        $script:LogHour = $null
    }

    Context 'Functionality tests' {
        It 'creates default log directory and file' {
            Write-Status -Level INFO -Message 'init'
            Test-Path $script:LogDirectory | Should -BeTrue
            Test-Path $script:StatusLogFile | Should -BeTrue
        }

        It 'logs INFO with greater-than symbol' {
            Write-Status -Level INFO -Message 'info message'
            (Get-Content $script:StatusLogFile | Select-Object -Last 1) | Should -Match '\[>\] info message'
        }

        It 'logs WARN with exclamation symbol' {
            Write-Status -Level WARN -Message 'warn message'
            (Get-Content $script:StatusLogFile | Select-Object -Last 1) | Should -Match '\[!\] warn message'
        }

        It 'logs ERROR with X symbol' {
            Write-Status -Level ERROR -Message 'error message' -ErrorAction SilentlyContinue
            (Get-Content $script:StatusLogFile | Select-Object -Last 1) | Should -Match '\[X\] error message'
        }

        It 'logs SUCCESS with plus symbol' {
            Write-Status -Level SUCCESS -Message 'success message'
            (Get-Content $script:StatusLogFile | Select-Object -Last 1) | Should -Match '\[\+\] success message'
        }

        It 'logs DEBUG with star symbol' {
            Write-Status -Level DEBUG -Message 'debug message'
            (Get-Content $script:StatusLogFile | Select-Object -Last 1) | Should -Match '\[*\] debug message'
        }

        It 'logs message when Fast switch is used' {
            Write-Status -Level INFO -Message 'fast message' -Fast
            (Get-Content $script:StatusLogFile | Select-Object -Last 1) | Should -Match 'fast message'
        }

        It 'uses custom log file path' {
            $custom = Join-Path $TestDrive 'custom' 'log.txt'
            Write-Status -Level INFO -Message 'custom path' -LogFile $custom
            $script:StatusLogFile | Should -Be $custom
            (Get-Content $custom | Select-Object -Last 1) | Should -Match 'custom path'
        }


        It 'logs errors to error log' {
            Write-Status -Level ERROR -Message 'failure' -ErrorAction SilentlyContinue
            Test-Path $script:ErrorLogFile | Should -BeTrue
            (Get-Content $script:ErrorLogFile | Select-Object -Last 1) | Should -Match 'failure'
        }
    }

    Context 'Edge case tests' {
        It 'throws when level is invalid' {
            { Write-Status -Level INVALID -Message 'oops' } | Should -Throw
        }

        It 'logs empty message' {
            { Write-Status -Level INFO -Message '' } | Should -Throw
        }

        It 'creates directory for custom log file path' {
            $custom = Join-Path $TestDrive 'nested' 'dir' 'log.txt'
            Write-Status -Level INFO -Message 'make dir' -LogFile $custom
            Test-Path (Split-Path -Path $custom -Parent) | Should -BeTrue
        }

        It 'rotates log file when hour changes' {
            Write-Status -Level INFO -Message 'first'
            $first = $script:StatusLogFile
            Set-WriteStatusConfig -LogDirectory (Join-Path $TestDrive 'rotated')
            $script:StatusLogFile = $null
            $script:LogHour = '1990-01-01_00'
            Write-Status -Level INFO -Message 'second'
            $script:StatusLogFile | Should -Not -Be $first
        }

    }
    Context "console colors" {
        BeforeEach {
            Mock Write-Host {}
        $VerbosePreference = "Continue"
        }
        It "writes INFO in cyan" {
            Write-Status -Level INFO -Message "color"
            Assert-MockCalled -CommandName Write-Host -Times 1 -ParameterFilter { $ForegroundColor -eq "Cyan" }
        }
        It "writes SUCCESS in green" {
            Write-Status -Level SUCCESS -Message "good"
            Assert-MockCalled -CommandName Write-Host -Times 1 -ParameterFilter { $ForegroundColor -eq "Green" }
        }
    }

}
