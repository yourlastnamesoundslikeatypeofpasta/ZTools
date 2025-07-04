Describe 'Start-PdfRenameWatcher function' {
    BeforeAll {
        $core = Join-Path $PSScriptRoot '..' 'src'
        . (Join-Path $core 'Write-Status.ps1')
        . (Join-Path $core 'PdfTools' 'Start-PdfRenameWatcher.ps1')
    }

    BeforeEach {
        Mock Write-Status {}
    }

    It 'logs error when directory is missing' {
        Start-PdfRenameWatcher -Path 'Z:\missing' -OpenAIKey 'test' -Model 'test' -ErrorAction SilentlyContinue
        Assert-MockCalled -CommandName Write-Status -ParameterFilter { $Level -eq 'ERROR' } -Times 1
    }
}
