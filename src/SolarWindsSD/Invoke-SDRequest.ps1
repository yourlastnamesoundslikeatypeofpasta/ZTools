function Invoke-SDRequest {
    <#
    .SYNOPSIS
        Invokes a REST request against SolarWinds Service Desk.
    .DESCRIPTION
        Internal helper used by other functions to call the API.
    .PARAMETER Method
        HTTP method such as GET or PATCH.
    .PARAMETER Path
        API path starting with '/'.
    .PARAMETER Body
        Optional hashtable representing the JSON body.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Path,

        [hashtable]$Body
    )

    if (-not $script:SDSBaseUrl -or -not $script:SDHeaders) {
        throw 'Session not initialized. Call New-SDSession first.'
    }

    $uri = "$script:SDSBaseUrl$Path"
    $params = @{ Uri = $uri; Method = $Method; Headers = $script:SDHeaders; ErrorAction = $ErrorActionPreference }
    if ($Body) { $params.Body = ($Body | ConvertTo-Json -Depth 5) }
    Invoke-RestMethod @params
}

if ($MyInvocation.InvocationName -ne '.') {
    Invoke-SDRequest @PSBoundParameters
}
