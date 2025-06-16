$configuration = New-PesterConfiguration
$configuration.Run.Path = 'tests'
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = @('src')
$configuration.CodeCoverage.OutputFormat = 'JaCoCo'
$configuration.CodeCoverage.OutputPath = 'coverage.xml'
$configuration
