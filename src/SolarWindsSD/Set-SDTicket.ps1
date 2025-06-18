function Set-SDTicket {
    <#
    .SYNOPSIS
        Updates one or more SolarWinds Service Desk tickets.
    .DESCRIPTION
        Sends a PATCH request to /incidents/{id}. To avoid accidental mass
        updates, more than five tickets require the -Force switch.
        See https://apidoc.samanage.com/#section/General-Concepts for API details.
    .PARAMETER Id
        One or more ticket IDs to update.
    .PARAMETER Properties
        Hashtable of fields to update.
    .PARAMETER Force
        Bypass the safeguard that limits updates to five tickets at a time.
    .EXAMPLE
        Set-SDTicket -Id 1 -Properties @{ state = 'Resolved' }
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int[]]$Id,

        [Parameter(Mandatory)]
        [hashtable]$Properties,

        [switch]$Force
    )

    begin {
        $rootPath = Split-Path $PSScriptRoot -Parent
        $ztPath   = Join-Path -Path $rootPath -ChildPath 'ZtCore/ZtEntity.ps1'
        if (-not ('ZtEntity' -as [type])) { . $ztPath }
        if ($Id.Count -gt 5 -and -not $Force) {
            throw 'Updating more than five tickets requires -Force.'
        }
    }
    process {
        foreach ($ticketId in $Id) {
            $body = @{ incident = $Properties }
            if ($PSCmdlet.ShouldProcess("ticket $ticketId")) {
                Write-Status -Level INFO -Message "Updating ticket $ticketId" -Fast
                Invoke-SDRequest -Method PATCH -Path "/incidents/$ticketId" -Body $body | Out-Null
                $props = @{ Updated = $true; Properties = $Properties }
                [ZtEntity]::new('SolarWindsSD','Ticket',$ticketId,$props)
            }
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Set-SDTicket @PSBoundParameters
}
