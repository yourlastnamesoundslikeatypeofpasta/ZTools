# <#
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
# #>
function Set-ComputerIPAddress {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$IPAddress,

        [int]$PrefixLength = 24,

        [string]$DefaultGateway,

        [string[]]$DnsServerAddress = '8.8.8.8',

        [string]$AdapterName = 'Ethernet'
    )

    $adapter = Get-NetAdapter -Name $AdapterName
    if (-not $adapter) {
        Write-Status -Level ERROR -Message "Adapter '$AdapterName' not found." -Fast
        return
    }

    if (-not $PSCmdlet.ShouldProcess($IPAddress, 'Configure IP')) { return }

    $config = $adapter | Get-NetIPConfiguration
    if ($config.IPv4Address) {
        $adapter | Remove-NetIPAddress -AddressFamily IPv4 -Confirm:$false
    }
    if ($config.IPv4DefaultGateway) {
        $adapter | Remove-NetRoute -AddressFamily IPv4 -Confirm:$false
    }

    $params = @{ AddressFamily = 'IPv4'; IPAddress = $IPAddress; PrefixLength = $PrefixLength }
    if ($DefaultGateway) { $params.DefaultGateway = $DefaultGateway }
    $adapter | New-NetIPAddress @params

    if ($DnsServerAddress) {
        $adapter | Set-DnsClientServerAddress -ServerAddresses $DnsServerAddress
    }

    Restart-NetAdapter -Name $AdapterName
    Clear-DnsClientCache
    Write-Status -Level SUCCESS -Message 'IP address configured.' -Fast
}

if ($MyInvocation.InvocationName -ne '.') {
    Set-ComputerIPAddress @PSBoundParameters
}
