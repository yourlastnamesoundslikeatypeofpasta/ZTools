function Get-DiskUsage {
    <#
    .SYNOPSIS
        Gets disk usage information.
    .DESCRIPTION
        Returns disk usage metrics for each file system drive using Get-PSDrive.
    .EXAMPLE
        Get-DiskUsage
    #>
    [CmdletBinding()]
    param()

    try {
        Get-PSDrive -PSProvider FileSystem |
            Where-Object { $_.Free -ne $null } |
            ForEach-Object {
                $total = $_.Used + $_.Free
                [pscustomobject]@{
                    Drive       = $_.Root
                    TotalGB     = [math]::Round($total/1GB,2)
                    UsedGB      = [math]::Round($_.Used/1GB,2)
                    FreeGB      = [math]::Round($_.Free/1GB,2)
                    PercentUsed = if ($total -eq 0) { 0 } else { [math]::Round(($_.Used/$total)*100,2) }
                }
            }
    }
    catch {
        Write-Status -Level ERROR -Message $_.Exception.Message -Fast
        return $null
    }
}
