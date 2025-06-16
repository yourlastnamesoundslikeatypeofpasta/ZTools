<#
.SYNOPSIS
Exports the Windows product key to a file.

.DESCRIPTION
Retrieves the original product key from the SoftwareLicensingService WMI class
and writes it to the specified path. Optionally logs a transcript of the session.

.PARAMETER OutputPath
Destination file path for the exported product key.

.PARAMETER TranscriptPath
Optional path to create a transcript log.

.EXAMPLE
Export-ProductKey -OutputPath ./key.txt

.NOTES
Administrator privileges are required to query the licensing service.
#>
function Export-ProductKey {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    try {
        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

        try {
            $key = Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction Stop |
                   Select-Object -ExpandProperty OA3xOriginalProductKey
        } catch {
            Write-Error $_.Exception.Message
            throw
        }

        if (-not $key) {
            Write-Status -Level WARN -Message 'Product key not found.' -Fast
            return
        }

        if (-not $PSCmdlet.ShouldProcess($OutputPath, 'Export product key')) { return }

        try {
            Set-Content -Path $OutputPath -Value $key -ErrorAction Stop
        } catch {
            Write-Error $_.Exception.Message
            throw
        }

        Write-Status -Level SUCCESS -Message "Product key exported to $OutputPath" -Fast
        return [pscustomobject]@{
            ProductKey = $key
            OutputPath = $OutputPath
        }
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}

# Entry point
if ($MyInvocation.InvocationName -ne '.') {
    Export-ProductKey @PSBoundParameters
}
