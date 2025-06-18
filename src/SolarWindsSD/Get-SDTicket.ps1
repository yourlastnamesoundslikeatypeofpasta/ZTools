function Get-SDTicket {
    <#
    .SYNOPSIS
        Retrieves a ticket from SolarWinds Service Desk.
    .DESCRIPTION
        Queries the /incidents/{id} endpoint.
    .PARAMETER Id
        Ticket identifier to retrieve.
    .EXAMPLE
        Get-SDTicket -Id 42
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [int]$Id
    )

    begin {
        $rootPath = Split-Path $PSScriptRoot -Parent
        $ztPath   = Join-Path -Path $rootPath -ChildPath 'ZtCore/ZtEntity.ps1'
        if (-not ('ZtEntity' -as [type])) { . $ztPath }
    }
    process {
        Write-Status -Level INFO -Message "Fetching ticket $Id" -Fast
        $ticket = Invoke-SDRequest -Method GET -Path "/incidents/$Id"
        $props = @{}
        $ticket.psobject.Properties | ForEach-Object { $props[$_.Name] = $_.Value }
        return [ZtEntity]::new('SolarWindsSD','Ticket',$ticket.id,$props)
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Get-SDTicket @PSBoundParameters
}
