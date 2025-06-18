function Set-SDConfig {
    <#
    .SYNOPSIS
        Stores SolarWinds Service Desk configuration.
    .DESCRIPTION
        Prompts for the base URL and API token or accepts them via parameters.
        The values are saved in a SecretManagement vault (SecretStore) under
        'ZTools.SolarWindsSD.BaseUrl' and 'ZTools.SolarWindsSD.ApiToken'.
    .PARAMETER BaseUrl
        Base URL of the Service Desk instance (e.g. https://api.samanage.com).
    .PARAMETER ApiToken
        Personal API token used for authentication.
    .EXAMPLE
        Set-SDConfig -BaseUrl 'https://api.samanage.com' -ApiToken 'token'
    #>
    [CmdletBinding()]
    param(
        [string]$BaseUrl,
        [string]$ApiToken
    )

    begin {
        $rootPath       = Split-Path $PSScriptRoot -Parent
        $writeStatusPath = Join-Path -Path $rootPath -ChildPath 'Write-Status.ps1'
        $ztPath         = Join-Path -Path $rootPath -ChildPath 'ZtCore/ZtEntity.ps1'
        . $writeStatusPath
        if (-not ('ZtEntity' -as [type])) { . $ztPath }
        # Use SecretManagement/SecretStore for cross-platform credential storage
        Import-Module Microsoft.PowerShell.SecretManagement -ErrorAction Stop

        # Ensure a default vault exists so secrets can be saved.
        # Some test environments may not have the SecretManagement cmdlets
        # available, so verify the commands exist before calling them.
        if (Get-Command -Name Get-SecretVault -ErrorAction SilentlyContinue) {
            if (-not (Get-SecretVault -ErrorAction SilentlyContinue)) {
                if (-not (Get-Module -ListAvailable Microsoft.PowerShell.SecretStore)) {
                    Write-Status -Level ERROR -Message 'Microsoft.PowerShell.SecretStore module not found.' -Fast
                    throw 'SecretStore module is required but not installed.'
                }

                if (-not (Get-SecretVault -Name 'SecretStore' -ErrorAction SilentlyContinue)) {
                    Register-SecretVault -Name 'SecretStore' -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault -ErrorAction Stop
                } else {
                    Set-SecretVaultDefault -Name 'SecretStore'
                }
            }
        } else {
            Write-Status -Level WARN -Message 'SecretManagement commands not available; skipping vault check.' -Fast
        }
    }
    process {
        if (-not $BaseUrl) {
            $BaseUrl = Read-Host -Prompt 'Enter SolarWinds Service Desk base URL'
        }
        if (-not $ApiToken) {
            $ApiToken = Read-Host -Prompt 'Enter API token'
        }
        try {
            # Store the base URL as a credential in the SecretStore
            $baseUrlCred = [pscredential]::new('BaseUrl', (ConvertTo-SecureString $BaseUrl -AsPlainText -Force))
            Set-Secret -Name 'ZTools.SolarWindsSD.BaseUrl' -Secret $baseUrlCred

            # Store the API token securely in the SecretStore
            $apiTokenCred = [pscredential]::new('ApiToken', (ConvertTo-SecureString $ApiToken -AsPlainText -Force))
            Set-Secret -Name 'ZTools.SolarWindsSD.ApiToken' -Secret $apiTokenCred

            Write-Status -Level SUCCESS -Message 'SolarWinds Service Desk configuration stored.' -Fast
            $props = @{ BaseUrl = $BaseUrl }
            return [ZtEntity]::new('SolarWindsSD','Config','Default',$props)
        } catch {
            Write-Status -Level ERROR -Message $_.Exception.Message -Fast
            throw
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Set-SDConfig @PSBoundParameters
}
