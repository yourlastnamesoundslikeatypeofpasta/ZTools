function Set-SDConfig {
    <#
    .SYNOPSIS
        Stores SolarWinds Service Desk configuration.
    .DESCRIPTION
        Prompts for the base URL and API token or accepts them via parameters.
        The values are saved in Windows Credential Manager under
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
        Import-Module CredentialManager -ErrorAction Stop
    }
    process {
        if (-not $BaseUrl) {
            $BaseUrl = Read-Host -Prompt 'Enter SolarWinds Service Desk base URL'
        }
        if (-not $ApiToken) {
            $ApiToken = Read-Host -Prompt 'Enter API token'
        }
        try {
            New-StoredCredential -Target 'ZTools.SolarWindsSD.BaseUrl' -Type Generic -UserName 'BaseUrl' -Password $BaseUrl -Persist LocalMachine | Out-Null
            New-StoredCredential -Target 'ZTools.SolarWindsSD.ApiToken' -Type Generic -UserName 'ApiToken' -Password $ApiToken -Persist LocalMachine | Out-Null
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
