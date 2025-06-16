<#
# .SYNOPSIS
# Configures a network adapter with a static IPv4 address.
#
# .DESCRIPTION
# Sets the IPv4 address, gateway and DNS servers for the specified adapter. Any
# existing IPv4 addresses and routes are removed before applying the new
# configuration.
#
# .PARAMETER IPAddress
# Static IPv4 address to apply.
#
# .PARAMETER PrefixLength
# Subnet prefix length. Defaults to 24.
#
# .PARAMETER DefaultGateway
# Optional default gateway address.
#
# .PARAMETER DnsServerAddress
# Optional DNS server addresses. Defaults to '8.8.8.8'.
#
# .PARAMETER AdapterName
# Name of the network adapter to configure. Defaults to 'Ethernet'.
#
# .EXAMPLE
# Set-ComputerIPAddress -IPAddress 10.0.0.5 -DefaultGateway 10.0.0.1
#
# .NOTES
# Must be run locally on the target machine.
#>


function Set-ComputerIPAddress {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Net.IPAddress]$IPAddress,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]$PrefixLength = 24,

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Net.IPAddress]$DefaultGateway,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]$DnsServerAddress = '8.8.8.8',

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$AdapterName = 'Ethernet'
    )

    begin {
        if (-not (Test-IsAdministrator)) {
            Write-Status -Level ERROR -Message 'Administrator privileges are required.' -Fast
            return
        }
    }

    process {
        try {
            $adapter = Get-NetAdapter -Name $AdapterName -ErrorAction Stop
        } catch {
            Write-Status -Level ERROR -Message "Adapter '$AdapterName' not found." -Fast
            return
        }
        if (-not $adapter) {
            Write-Status -Level ERROR -Message "Adapter '$AdapterName' not found." -Fast
            return
        }

        if (-not $PSCmdlet.ShouldProcess($IPAddress, 'Configure IP')) { return }

        try {
            $config = $adapter | Get-NetIPConfiguration -ErrorAction Stop
            if ($config.IPv4Address) {
                $adapter | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:$false -ErrorAction Stop
            }
            if ($config.IPv4DefaultGateway) {
                $adapter | Remove-NetRoute -AddressFamily IPv4 -Confirm:$false -ErrorAction Stop
            }

            $params = @{ AddressFamily = 'IPv4'; IPAddress = $IPAddress.IPAddressToString; PrefixLength = $PrefixLength }
            if ($DefaultGateway) { $params.DefaultGateway = $DefaultGateway.IPAddressToString }
            $adapter | New-NetIPAddress @params -ErrorAction Stop

            if ($DnsServerAddress) {
                $adapter | Set-DnsClientServerAddress -ServerAddresses $DnsServerAddress -ErrorAction Stop
            }

            Restart-NetAdapter -Name $AdapterName -ErrorAction Stop
            Clear-DnsClientCache -ErrorAction Stop
            Write-Status -Level SUCCESS -Message 'IP address configured.' -Fast
        } catch {
            Write-Error $_.Exception.Message
            throw
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Set-ComputerIPAddress @PSBoundParameters
}
