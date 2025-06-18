function New-SDSession {
    <#
    .SYNOPSIS
        Creates a session for SolarWinds Service Desk API.
    .DESCRIPTION
        Reads the base URL and API token from parameters or the credential
        manager. Values stored by Set-SDConfig are used when parameters are
        omitted. Refer to https://apidoc.samanage.com/#section/General-Concepts
        for details.
    .PARAMETER ApiToken
        Personal API token used for authentication.
    .PARAMETER BaseUrl
        Base URL of the Service Desk instance.
    .PARAMETER Region
        Optional region prefix (api, apieu or apiau) used when BaseUrl is not
        provided. Defaults to 'api'.
    .EXAMPLE
        New-SDSession -ApiToken 'token'
    #>
    [CmdletBinding()]
    param(
        [string]$ApiToken,
        [string]$BaseUrl,
        [ValidateSet('api','apieu','apiau')]
        [string]$Region = 'api'
    )

    begin {
        $rootPath = Split-Path $PSScriptRoot -Parent
        $ztPath   = Join-Path -Path $rootPath -ChildPath 'ZtCore/ZtEntity.ps1'
        if (-not ('ZtEntity' -as [type])) { . $ztPath }
        Import-Module CredentialManager -ErrorAction SilentlyContinue
        if (-not $ApiToken) {
            $cred = Get-StoredCredential -Target 'ZTools.SolarWindsSD.ApiToken'
            if ($cred) { $ApiToken = $cred.Password }
        }
        if (-not $BaseUrl) {
            $cred = Get-StoredCredential -Target 'ZTools.SolarWindsSD.BaseUrl'
            if ($cred) { $BaseUrl = $cred.Password }
        }
        if (-not $BaseUrl) {
            $BaseUrl = "https://$Region.samanage.com"
        }
        if (-not $ApiToken) {
            throw 'API token not provided and not found in Credential Manager.'
        }
    }
    process {
        $script:SDSBaseUrl = $BaseUrl
        $script:SDHeaders  = @{ 'X-Samanage-Authorization' = "Bearer $ApiToken"; 'Content-Type' = 'application/json' }
        Write-Status -Level INFO -Message 'SolarWinds Service Desk session initialized' -Fast
        $props = @{ BaseUrl = $BaseUrl }
        return [ZtEntity]::new('SolarWindsSD','Session',$BaseUrl,$props)
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    New-SDSession @PSBoundParameters
}
