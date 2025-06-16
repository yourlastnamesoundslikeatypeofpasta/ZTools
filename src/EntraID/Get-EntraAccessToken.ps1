<#
.SYNOPSIS
Retrieves an access token for Microsoft Graph using MSAL caching.

.DESCRIPTION
Uses the MSAL.PS module to acquire a token with optional device login.
Tenant ID, client ID and secret can be supplied as parameters or via
environment variables GRAPH_TENANT_ID, GRAPH_CLIENT_ID and GRAPH_CLIENT_SECRET.

.PARAMETER TenantId
Tenant identifier of the Azure AD/Entra ID tenant.

.PARAMETER ClientId
Application (client) ID used for authentication.

.PARAMETER ClientSecret
Client secret for the application when not using device login.

.PARAMETER DeviceLogin
Use device code flow instead of client secret.
#>
function Get-EntraAccessToken {
    [CmdletBinding()]
    param(
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret,
        [switch]$DeviceLogin
    )

    if (-not $TenantId)     { $TenantId     = $env:GRAPH_TENANT_ID }
    if (-not $ClientId)     { $ClientId     = $env:GRAPH_CLIENT_ID }
    if (-not $ClientSecret) { $ClientSecret = $env:GRAPH_CLIENT_SECRET }

    if (-not $TenantId) { throw 'TenantId is required. Provide -TenantId or set GRAPH_TENANT_ID.' }
    if (-not $ClientId) { throw 'ClientId is required. Provide -ClientId or set GRAPH_CLIENT_ID.' }

    $params = @{ TenantId = $TenantId; ClientId = $ClientId; Scopes = 'https://graph.microsoft.com/.default' }
    if ($ClientSecret -and -not $DeviceLogin) { $params.ClientSecret = $ClientSecret }

    try {
        $tokenResponse = Get-MsalToken @params -Silent
    } catch {
        if ($DeviceLogin -or -not $ClientSecret) {
            $tokenResponse = Get-MsalToken @params -DeviceCode
        } else {
            $tokenResponse = Get-MsalToken @params
        }
    }

    return $tokenResponse.AccessToken
}

# Entry point
if ($MyInvocation.InvocationName -ne '.') {
    Get-EntraAccessToken @PSBoundParameters
}
