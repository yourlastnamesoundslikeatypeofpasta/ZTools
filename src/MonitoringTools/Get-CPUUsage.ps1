function Get-CPUUsage {
    <#
    .SYNOPSIS
        Gets the current CPU utilization percentage.
    .DESCRIPTION
        Cross-platform helper that collects CPU usage metrics. On Windows it
        uses `Get-Counter`; on other systems it falls back to the `ps` command.
        Warnings are logged with `Write-Status` when metrics cannot be collected.
    .EXAMPLE
        Get-CPUUsage
    #>
    [CmdletBinding()]
    param()

    $computer = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } elseif ($env:HOSTNAME) { $env:HOSTNAME } else { 'localhost' }

    Write-Status -Level INFO -Message "Collecting CPU usage on $computer" -Fast

    try {
        if ($IsWindows -and (Get-Command Get-Counter -ErrorAction SilentlyContinue)) {
            $samples = Get-Counter '\\Processor(_Total)\\% Processor Time' -SampleInterval 1 -MaxSamples 3
            return [math]::Round(($samples.CounterSamples | Measure-Object -Property CookedValue -Average).Average, 2)
        }
        elseif (-not $IsWindows -and (Get-Command ps -ErrorAction SilentlyContinue)) {
            $cpuValues = ps -A -o %cpu | Select-Object -Skip 1 | ForEach-Object { $_ -as [double] }
            if ($cpuValues) {
                return [math]::Round(($cpuValues | Measure-Object -Average).Average, 2)
            } else {
                Write-Status -Level WARN -Message 'Unable to read CPU usage from ps.' -Fast
                return $null
            }
        }
        else {
            Write-Status -Level WARN -Message 'CPU metrics skipped: required tools not found.' -Fast
            return $null
        }
    }
    catch {
        Write-Status -Level ERROR -Message $_.Exception.Message -Fast -ErrorAction SilentlyContinue
        return $null
    }
}
