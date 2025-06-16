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
        elseif ($IsMacOS -and (Get-Command vm_stat -ErrorAction SilentlyContinue) -and (Get-Command sysctl -ErrorAction SilentlyContinue)) {
            $pageSize  = [int](sysctl -n hw.pagesize)
            $totalBytes = [int64](sysctl -n hw.memsize)
            $vmStat    = vm_stat
            $freeLine  = $vmStat | Where-Object { $_ -match '^Pages free:' } | Select-Object -First 1
            $inactiveLine = $vmStat | Where-Object { $_ -match '^Pages inactive:' } | Select-Object -First 1
            $specLine  = $vmStat | Where-Object { $_ -match '^Pages speculative:' } | Select-Object -First 1
            $freePages = ([regex]::Match($freeLine, '\d+').Value -as [int64])
            $inactivePages = ([regex]::Match($inactiveLine, '\d+').Value -as [int64])
            $specPages = ([regex]::Match($specLine, '\d+').Value -as [int64])
            $freeBytes = ($freePages + $inactivePages + $specPages) * $pageSize
            $totalMB = [math]::Round($totalBytes / 1MB, 2)
            $freeMB  = [math]::Round($freeBytes / 1MB, 2)
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
        Write-Status -Level ERROR -Message $_.Exception.Message -Fast -ErrorAction SilentlyContinue
        return $null
    }
}
