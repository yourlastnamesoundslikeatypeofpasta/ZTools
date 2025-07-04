Describe 'Start-PdfRenameWatcher function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
        Mock Test-Path { return $true }
        Mock Resolve-Path { return @{ Path = 'C:\TestPath' } }
        Mock New-Object { return @{ 
            IncludeSubdirectories = $false
            EnableRaisingEvents = $false
            NotifyFilter = [System.IO.NotifyFilters]::FileName
            Dispose = {}
        }}
        Mock Register-ObjectEvent { return @{ Name = 'PdfCreated' } }
        Mock Register-EngineEvent { return $null }
        Mock Start-Sleep {}
        Mock [Console]::KeyAvailable { return $false }
        Mock [Console]::ReadKey { return @{ Modifiers = [ConsoleModifiers]::Control; Key = 'C' } }
    }

    Context 'Parameter validation' {
        It 'logs error when directory is missing' {
            Mock Test-Path { return $false }
            Start-PdfRenameWatcher -Path 'Z:\missing' -OpenAIKey 'test' -Model 'test' -ErrorAction SilentlyContinue
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' } -Times 1
        }

        It 'logs error when OpenAI connection fails' {
            Mock Test-OpenAIConnection { return $false }
            Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'invalid' -ErrorAction SilentlyContinue
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' } -Times 1
        }

        It 'validates MaxFileSizeMB parameter range' {
            { Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'test' -MaxFileSizeMB 0 } | Should -Throw
            { Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'test' -MaxFileSizeMB 101 } | Should -Throw
        }

        It 'validates RetryCount parameter range' {
            { Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'test' -RetryCount 0 } | Should -Throw
            { Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'test' -RetryCount 11 } | Should -Throw
        }

        It 'validates RetryDelaySeconds parameter range' {
            { Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'test' -RetryDelaySeconds 0 } | Should -Throw
            { Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'test' -RetryDelaySeconds 61 } | Should -Throw
        }
    }

    Context 'Initialization and setup' {
        It 'resolves and validates path successfully' {
            Mock Test-OpenAIConnection { return $true }
            Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'valid' -ErrorAction SilentlyContinue
            Assert-MockCalled -CommandName Resolve-Path -Times 1
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'INFO' -and $Message -like '*Resolved path*' } -Times 1
        }

        It 'sets up file watcher with correct parameters' {
            Mock Test-OpenAIConnection { return $true }
            Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'valid' -ErrorAction SilentlyContinue
            Assert-MockCalled -CommandName New-Object -Times 1
            Assert-MockCalled -CommandName Register-ObjectEvent -Times 1
        }

        It 'logs success message when started' {
            Mock Test-OpenAIConnection { return $true }
            Start-PdfRenameWatcher -Path 'C:\Test' -OpenAIKey 'valid' -ErrorAction SilentlyContinue
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'SUCCESS' } -Times 1
        }
    }
}

Describe 'Process-PdfFile function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
        Mock Start-Sleep {}
        Mock Test-PdfFile { return $true }
        Mock Invoke-WithRetry { return 'test-file-id' }
        Mock Get-CleanFileName { return 'CleanFileName' }
        Mock Get-UniqueFileName { return 'UniqueFileName' }
        Mock Rename-Item {}
        Mock Remove-OpenAIFile {}
    }

    Context 'File processing workflow' {
        It 'processes valid PDF file successfully' {
            Process-PdfFile -FilePath 'C:\test.pdf' -OpenAIKey 'test' -Model 'gpt-4' -MaxFileSizeBytes 25MB -RetryCount 3 -RetryDelaySeconds 5
            Assert-MockCalled -CommandName Test-PdfFile -Times 1
            Assert-MockCalled -CommandName Invoke-WithRetry -Times 2
            Assert-MockCalled -CommandName Rename-Item -Times 1
            Assert-MockCalled -CommandName Remove-OpenAIFile -Times 1
        }

        It 'skips processing when file validation fails' {
            Mock Test-PdfFile { return $false }
            Process-PdfFile -FilePath 'C:\test.pdf' -OpenAIKey 'test' -Model 'gpt-4' -MaxFileSizeBytes 25MB -RetryCount 3 -RetryDelaySeconds 5
            Assert-MockCalled -CommandName Invoke-WithRetry -Times 0
            Assert-MockCalled -CommandName Rename-Item -Times 0
        }

        It 'handles upload failure gracefully' {
            Mock Invoke-WithRetry { return $null } -ParameterFilter { $Operation -eq 'Upload' }
            Process-PdfFile -FilePath 'C:\test.pdf' -OpenAIKey 'test' -Model 'gpt-4' -MaxFileSizeBytes 25MB -RetryCount 3 -RetryDelaySeconds 5
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' -and $Message -like '*Failed to upload*' } -Times 1
            Assert-MockCalled -CommandName Rename-Item -Times 0
        }

        It 'handles name generation failure gracefully' {
            Mock Invoke-WithRetry { 
                if ($Operation -eq 'Upload') { return 'test-file-id' }
                return $null 
            }
            Process-PdfFile -FilePath 'C:\test.pdf' -OpenAIKey 'test' -Model 'gpt-4' -MaxFileSizeBytes 25MB -RetryCount 3 -RetryDelaySeconds 5
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' -and $Message -like '*Failed to generate filename*' } -Times 1
            Assert-MockCalled -CommandName Rename-Item -Times 0
        }

        It 'handles invalid generated filename' {
            Mock Get-CleanFileName { return $null }
            Process-PdfFile -FilePath 'C:\test.pdf' -OpenAIKey 'test' -Model 'gpt-4' -MaxFileSizeBytes 25MB -RetryCount 3 -RetryDelaySeconds 5
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' -and $Message -like '*Generated filename is invalid*' } -Times 1
            Assert-MockCalled -CommandName Rename-Item -Times 0
        }

        It 'cleans up OpenAI file even when rename fails' {
            Mock Rename-Item { throw 'Rename failed' }
            Process-PdfFile -FilePath 'C:\test.pdf' -OpenAIKey 'test' -Model 'gpt-4' -MaxFileSizeBytes 25MB -RetryCount 3 -RetryDelaySeconds 5
            Assert-MockCalled -CommandName Remove-OpenAIFile -Times 1
        }
    }
}

Describe 'Test-PdfFile function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
    }

    Context 'File validation' {
        It 'returns false when file does not exist' {
            Mock Test-Path { return $false }
            Test-PdfFile -FilePath 'C:\missing.pdf' -MaxFileSizeBytes 25MB | Should -Be $false
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'WARNING' -and $Message -like '*no longer exists*' } -Times 1
        }

        It 'returns false when file is empty' {
            Mock Test-Path { return $true }
            Mock Get-Item { return @{ Length = 0 } }
            Test-PdfFile -FilePath 'C:\empty.pdf' -MaxFileSizeBytes 25MB | Should -Be $false
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'WARNING' -and $Message -like '*is empty*' } -Times 1
        }

        It 'returns false when file is too large' {
            Mock Test-Path { return $true }
            Mock Get-Item { return @{ Length = 30MB } }
            Test-PdfFile -FilePath 'C:\large.pdf' -MaxFileSizeBytes 25MB | Should -Be $false
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'WARNING' -and $Message -like '*too large*' } -Times 1
        }

        It 'returns true for valid file' {
            Mock Test-Path { return $true }
            Mock Get-Item { return @{ Length = 10MB } }
            Test-PdfFile -FilePath 'C:\valid.pdf' -MaxFileSizeBytes 25MB | Should -Be $true
        }
    }
}

Describe 'Test-OpenAIConnection function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
    }

    Context 'OpenAI connection testing' {
        It 'returns true for successful connection' {
            Mock Invoke-RestMethod { return @{ id = 'test' } }
            Test-OpenAIConnection -ApiKey 'valid-key' | Should -Be $true
        }

        It 'returns false for failed connection' {
            Mock Invoke-RestMethod { throw 'Connection failed' }
            Test-OpenAIConnection -ApiKey 'invalid-key' | Should -Be $false
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' -and $Message -like '*connection test failed*' } -Times 1
        }
    }
}

Describe 'Upload-OpenAIFile function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
        Mock Write-Progress {}
        Mock Get-Item { return @{ Name = 'test.pdf' } }
    }

    Context 'File upload' {
        It 'returns file ID on successful upload' {
            Mock Invoke-RestMethod { return @{ id = 'file-123' } }
            Upload-OpenAIFile -Path 'C:\test.pdf' -ApiKey 'test-key' | Should -Be 'file-123'
            Assert-MockCalled -CommandName Write-Progress -Times 2
        }

        It 'returns null on upload failure' {
            Mock Invoke-RestMethod { throw 'Upload failed' }
            Upload-OpenAIFile -Path 'C:\test.pdf' -ApiKey 'test-key' | Should -Be $null
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' -and $Message -like '*Upload failed*' } -Times 1
        }
    }
}

Describe 'Get-OpenAIPdfName function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
        Mock ConvertTo-Json { return '{"test":"json"}' }
    }

    Context 'PDF name generation' {
        It 'returns generated filename on success' {
            Mock Invoke-RestMethod { return @{ choices = @(@{ message = @{ content = '  Test Document  ' } }) } }
            Get-OpenAIPdfName -FileId 'file-123' -ApiKey 'test-key' -Model 'gpt-4' | Should -Be 'Test Document'
        }

        It 'returns null on API failure' {
            Mock Invoke-RestMethod { throw 'API failed' }
            Get-OpenAIPdfName -FileId 'file-123' -ApiKey 'test-key' -Model 'gpt-4' | Should -Be $null
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' -and $Message -like '*OpenAI request failed*' } -Times 1
        }

        It 'uses default model when not specified' {
            Mock Invoke-RestMethod { return @{ choices = @(@{ message = @{ content = 'Test' } }) } }
            Get-OpenAIPdfName -FileId 'file-123' -ApiKey 'test-key' | Should -Be 'Test'
        }
    }
}

Describe 'Remove-OpenAIFile function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
    }

    Context 'File cleanup' {
        It 'successfully removes file' {
            Mock Invoke-RestMethod {}
            { Remove-OpenAIFile -FileId 'file-123' -ApiKey 'test-key' } | Should -Not -Throw
        }

        It 'handles cleanup failure gracefully' {
            Mock Invoke-RestMethod { throw 'Delete failed' }
            { Remove-OpenAIFile -FileId 'file-123' -ApiKey 'test-key' } | Should -Not -Throw
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'WARNING' -and $Message -like '*Failed to clean up*' } -Times 1
        }
    }
}

Describe 'Get-CleanFileName function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    Context 'Filename cleaning' {
        It 'removes invalid characters' {
            Get-CleanFileName -Name 'file<>:"|?*name' | Should -Be 'file----name'
        }

        It 'cleans up multiple dashes' {
            Get-CleanFileName -Name 'file---name' | Should -Be 'file-name'
        }

        It 'trims spaces and dashes' {
            Get-CleanFileName -Name '  file-name  ' | Should -Be 'file-name'
        }

        It 'returns null for empty string' {
            Get-CleanFileName -Name '' | Should -Be $null
        }

        It 'returns null for whitespace only' {
            Get-CleanFileName -Name '   ' | Should -Be $null
        }

        It 'returns null for string with only invalid characters' {
            Get-CleanFileName -Name '<<>>' | Should -Be $null
        }

        It 'preserves valid characters' {
            Get-CleanFileName -Name 'Valid-File_Name 123' | Should -Be 'Valid-File_Name 123'
        }
    }
}

Describe 'Get-UniqueFileName function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Test-Path { return $false }
    }

    Context 'Unique filename generation' {
        It 'returns original name when file does not exist' {
            Get-UniqueFileName -BaseName 'test' -Directory 'C:\Test' | Should -Be 'test'
        }

        It 'adds counter when file exists' {
            Mock Test-Path { 
                param($Path)
                return $Path -eq 'C:\Test\test.pdf'
            }
            Get-UniqueFileName -BaseName 'test' -Directory 'C:\Test' | Should -Be 'test_1'
        }

        It 'increments counter for multiple conflicts' {
            Mock Test-Path { 
                param($Path)
                return $Path -in @('C:\Test\test.pdf', 'C:\Test\test_1.pdf')
            }
            Get-UniqueFileName -BaseName 'test' -Directory 'C:\Test' | Should -Be 'test_2'
        }
    }
}

Describe 'Invoke-WithRetry function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
        Mock Start-Sleep {}
    }

    Context 'Retry logic' {
        It 'returns result on first successful attempt' {
            $scriptBlock = { return 'success' }
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelaySeconds 1 -Operation 'Test' | Should -Be 'success'
        }

        It 'retries on failure and succeeds' {
            $attempts = 0
            $scriptBlock = { 
                $attempts++
                if ($attempts -lt 3) { throw 'Failed' }
                return 'success'
            }
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelaySeconds 1 -Operation 'Test' | Should -Be 'success'
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'WARNING' -and $Message -like '*attempt 1 failed*' } -Times 1
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'WARNING' -and $Message -like '*attempt 2 failed*' } -Times 1
        }

        It 'returns null after all retries fail' {
            $scriptBlock = { throw 'Always fails' }
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 2 -RetryDelaySeconds 1 -Operation 'Test' | Should -Be $null
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' -and $Message -like '*failed after 2 attempts*' } -Times 1
        }

        It 'returns null when script block returns null' {
            $scriptBlock = { return $null }
            Invoke-WithRetry -ScriptBlock $scriptBlock -RetryCount 3 -RetryDelaySeconds 1 -Operation 'Test' | Should -Be $null
        }
    }
}

Describe 'Cleanup-Resources function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
        Mock Unregister-Event {}
        Mock Remove-Job {}
    }

    Context 'Resource cleanup' {
        It 'cleans up event job when present' {
            $script:EventJob = @{ Name = 'PdfCreated' }
            Cleanup-Resources
            Assert-MockCalled -CommandName Unregister-Event -Times 1
            Assert-MockCalled -CommandName Remove-Job -Times 1
        }

        It 'cleans up watcher when present' {
            $script:Watcher = @{ 
                EnableRaisingEvents = $true
                Dispose = {}
            }
            Mock $script:Watcher.Dispose {}
            Cleanup-Resources
            $script:Watcher.EnableRaisingEvents | Should -Be $false
        }

        It 'logs cleanup completion' {
            Cleanup-Resources
            Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'INFO' -and $Message -like '*stopped*' } -Times 1
        }

        It 'handles cleanup when resources are null' {
            $script:EventJob = $null
            $script:Watcher = $null
            { Cleanup-Resources } | Should -Not -Throw
        }
    }
}
