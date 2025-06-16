<#
.SYNOPSIS
Configures the local computer's IP address using a CSV mapping.
.DESCRIPTION
Imports a CSV file with `ComputerName` and `StaticIPAddress` columns and sets the
IP configuration for the matching computer. Only the Ethernet adapter is
modified. Existing IPv4 addresses and default routes are removed before applying
the new settings.
.PARAMETER CSVPath
Path to the CSV file containing computer/IP mappings.
.EXAMPLE
Set-ComputerIPAddress -CSVPath .\Computers.csv
.NOTES
Must be run locally on the target machine.
#>
function Set-ComputerIPAddress {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [string]$CSVPath
    )

    if (-not (Test-Path $CSVPath)) {
        Write-Status -Level ERROR -Message 'CSV file not found.' -Fast
        return
    }

    $entries = Import-Csv -Path $CSVPath
    if (-not $entries) {
        Write-Status -Level ERROR -Message 'CSV file not found.' -Fast
        return
    }

    $adapter = Get-NetAdapter -Name 'Ethernet'
    if (-not $adapter) {
        Write-Status -Level ERROR -Message 'Ethernet adapter not found.' -Fast
        return
    }

    foreach ($entry in $entries) {
        if ($entry.ComputerName -eq $env:COMPUTERNAME) {
            if ($PSCmdlet.ShouldProcess($entry.StaticIPAddress, 'Configure IP')) {
                $config = $adapter | Get-NetIPConfiguration
                if ($config.IPv4Address) {
                    $adapter | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:$false
                }
                if ($config.IPv4DefaultGateway) {
                    $adapter | Remove-NetRoute -AddressFamily IPv4 -Confirm:$false
                }
                $adapter | New-NetIPAddress -AddressFamily IPv4 -IPAddress $entry.StaticIPAddress -PrefixLength 24 -DefaultGateway '192.168.1.1'
                $adapter | Set-DnsClientServerAddress -ServerAddresses '8.8.8.8'
                Restart-NetAdapter -Name 'Ethernet'
                Clear-DnsClientCache
                Write-Status -Level SUCCESS -Message 'IP address configured.' -Fast
            }
            return
        }
    }
    Write-Status -Level WARN -Message 'No matching computer name found in CSV file.' -Fast
}

if ($MyInvocation.InvocationName -ne '.') {
    Set-ComputerIPAddress @PSBoundParameters
}
