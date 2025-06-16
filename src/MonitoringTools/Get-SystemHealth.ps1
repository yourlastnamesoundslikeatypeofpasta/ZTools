function Get-SystemHealth {
    <#
    .SYNOPSIS
        Provides a basic overview of system health.
    .DESCRIPTION
        Returns CPU usage, memory statistics, disk usage and domain information.
        This simplified health check demonstrates how monitoring data can be
        aggregated for later processing.
    .EXAMPLE
        Get-SystemHealth
    #>
    [CmdletBinding()]
    param()

    $cpu    = Get-CPUUsage
    $memory = Get-RAMUsage
    $disk   = Get-DiskUsage
    $domain = Get-DomainName

    [pscustomobject]@{
        CPUPercent = $cpu
        Memory     = $memory
        DiskInfo   = $disk
        DomainName = $domain
    }
}
