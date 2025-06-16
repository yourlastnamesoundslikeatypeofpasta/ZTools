<#
.SYNOPSIS
Retrieves a user's basic details from Microsoft Graph.

.DESCRIPTION
Queries the Microsoft Graph users endpoint and returns a [ZtEntity] object
containing select properties. Requires an access token that can be obtained
using Get-EntraAccessToken.

.PARAMETER UserPrincipalName
UPN of the user to query.

.PARAMETER TenantId
Tenant identifier used for authentication.

.PARAMETER ClientId
Application (client) ID used for authentication.

.PARAMETER ClientSecret
Client secret for the application when not using device login.

.PARAMETER DeviceLogin
Use device code flow instead of client secret.

.EXAMPLE
Get-EntraUser -UserPrincipalName user@contoso.com -TenantId <id> -ClientId <id>
#>
function Get-EntraUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$UserPrincipalName,
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret,
        [switch]$DeviceLogin
    )

    Write-Status -Level INFO -Message "Querying $UserPrincipalName" -Fast

    $token = Get-EntraAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret -DeviceLogin:$DeviceLogin
    $headers = @{ Authorization = "Bearer $token" }
    $url = "https://graph.microsoft.com/v1.0/users/$UserPrincipalName?`$select=id,displayName,userPrincipalName"
    $user = Invoke-RestMethod -Uri $url -Headers $headers -Method GET

    $props = @{ DisplayName = $user.displayName; UserPrincipalName = $user.userPrincipalName }
    return [ZtEntity]::new('EntraID','User',$user.id,$props)
}

# Entry point
if ($MyInvocation.InvocationName -ne '.') {
    Get-EntraUser @PSBoundParameters
}
