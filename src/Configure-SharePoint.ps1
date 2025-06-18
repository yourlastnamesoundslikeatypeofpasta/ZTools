<#
.SYNOPSIS
Prompts for SharePoint configuration and stores it in Windows Credential Manager.

.DESCRIPTION
Asks for the SharePoint tenant ID, app registration credential and user
credential. The values are saved as credentials under the names
`ZTools.SharePoint.TenantId`, `ZTools.SharePoint.Client` and
`ZTools.SharePoint.User` so they persist across reboots.

.PARAMETER TenantId
Optional tenant identifier. If omitted a prompt is shown.

.PARAMETER ClientCredential
App registration credential where the user name is the client ID and the
password is the client secret. If not supplied the user is prompted.

.PARAMETER UserCredential
User credential used for Graph or PnP connections. If not supplied the user is
prompted.

.EXAMPLE
./Configure-SharePoint.ps1
Prompts for all values and saves them in the credential manager.
#>
function Set-SharePointConfig {
    [CmdletBinding()]
    param(
        [string]$TenantId,
        [PSCredential]$ClientCredential,
        [PSCredential]$UserCredential
    )

    begin {
        $writeStatusPath = Join-Path -Path $PSScriptRoot -ChildPath 'Write-Status.ps1'
        . $writeStatusPath
        # Import SecretManagement for cross-platform credential storage
        Import-Module Microsoft.PowerShell.SecretManagement -ErrorAction Stop
    }
    process {
        if (-not $TenantId) {
            $TenantId = Read-Host -Prompt 'Enter SharePoint Tenant ID'
        }

        if (-not $ClientCredential) {
            $ClientCredential = Get-Credential -Message 'Enter Client ID as username and Client Secret as password'
        }

        if (-not $UserCredential) {
            $UserCredential = Get-Credential -Message 'Enter SharePoint user credentials'
        }

        try {
            # Store tenant ID as a credential
            $tenantCred = [pscredential]::new('TenantId', (ConvertTo-SecureString $TenantId -AsPlainText -Force))
            Set-Secret -Name 'ZTools.SharePoint.TenantId' -Secret $tenantCred

            # Store app registration and user credentials
            Set-Secret -Name 'ZTools.SharePoint.Client' -Secret $ClientCredential
            Set-Secret -Name 'ZTools.SharePoint.User'   -Secret $UserCredential

            Write-Status -Level SUCCESS -Message 'Configuration stored in SecretStore.' -Fast
        } catch {
            Write-Status -Level ERROR -Message $_.Exception.Message -Fast
            throw
        }
    }
}

# Entry point - only run when the script is not dot-sourced
if ($MyInvocation.InvocationName -ne '.') {
    Set-SharePointConfig @PSBoundParameters
}
