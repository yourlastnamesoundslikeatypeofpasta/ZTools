function Get-RAMUsage {
    <#
    .SYNOPSIS
        Gets memory usage statistics.
    .DESCRIPTION
        Cross-platform helper returning total, used, free memory and percent used in megabytes.
    .EXAMPLE
        Get-RAMUsage
    #>
    [CmdletBinding()]
    param()

    try {
        if ($IsWindows -and (Get-Command Get-CimInstance -ErrorAction SilentlyContinue)) {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem
            $totalMB = [math]::Round($os.TotalVisibleMemorySize / 1KB, 2)
            $freeMB  = [math]::Round($os.FreePhysicalMemory / 1KB, 2)
        }
        elseif (-not $IsWindows -and (Test-Path '/proc/meminfo')) {
            $memInfo = Get-Content '/proc/meminfo'
            $totalMB = ([regex]::Match($memInfo[0], '\d+').Value -as [double]) / 1024
            $availLine = $memInfo | Where-Object { $_ -match '^MemAvailable:' } | Select-Object -First 1
            if ($availLine) {
                $freeMB = ([regex]::Match($availLine, '\d+').Value -as [double]) / 1024
            } else {
                $freeLine = $memInfo | Where-Object { $_ -match '^MemFree:' } | Select-Object -First 1
                $freeMB = ([regex]::Match($freeLine, '\d+').Value -as [double]) / 1024
            }
        }
        else {
            Write-Status -Level WARN -Message 'Unable to read memory metrics.' -Fast
            return $null
        }

        $usedMB = [math]::Round($totalMB - $freeMB, 2)
        $percent = if ($totalMB -eq 0) { 0 } else { [math]::Round(($usedMB / $totalMB) * 100, 2) }

        [pscustomobject]@{
            TotalMB     = $totalMB
            UsedMB      = $usedMB
            FreeMB      = $freeMB
            PercentUsed = $percent
        }
    }
    catch {
        Write-Status -Level ERROR -Message $_.Exception.Message -Fast
        return $null
    }
}
