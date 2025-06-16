function Get-DomainName {
    <#
    .SYNOPSIS
        Gets the system domain name if available.
    .DESCRIPTION
        Attempts multiple methods to retrieve the domain or DNS name for the machine.
    .EXAMPLE
        Get-DomainName
    #>
    [CmdletBinding()]
    param()

    try {
        if (Get-Command Get-ADDomain -ErrorAction SilentlyContinue) {
            return (Get-ADDomain).DNSRoot
        }
    } catch {
        Write-Status -Level DEBUG -Message $_.Exception.Message -Fast
    }

    if ($env:USERDNSDOMAIN) { return $env:USERDNSDOMAIN }

    try {
        return [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
    } catch {
        Write-Status -Level WARN -Message 'Unable to determine domain name.' -Fast
        return $null
    }
}
