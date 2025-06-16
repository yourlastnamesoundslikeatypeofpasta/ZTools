Describe 'Configure-SharePoint script' {
    It 'imports Set-SharePointConfig function' {
        $scriptPath = Join-Path $PSScriptRoot '..' 'src' 'Configure-SharePoint.ps1'
        . $scriptPath
        Get-Command -Name Set-SharePointConfig -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }
}
