<#
.SYNOPSIS
    Watches a folder for new PDF files and renames them using OpenAI.
.DESCRIPTION
    Creates a FileSystemWatcher on the target folder. When a PDF file is dropped
    into the directory, the document is uploaded to the OpenAI API and a short
    descriptive name is requested. The file is then renamed to the suggested
    name.
    
    Features:
    - Automatic cleanup of uploaded files from OpenAI
    - Duplicate filename handling
    - Graceful shutdown with Ctrl+C
    - Enhanced error handling and logging
    - File size validation
    - Retry logic for failed operations
.PARAMETER Path
    Folder path to monitor for PDF files.
.PARAMETER OpenAIKey
    API key used when calling the OpenAI service.
.PARAMETER Model
    Optional model name for the chat completion request.
.PARAMETER MaxFileSizeMB
    Maximum file size in MB to process (default: 25MB).
.PARAMETER RetryCount
    Number of retries for failed operations (default: 3).
.PARAMETER RetryDelaySeconds
    Delay between retries in seconds (default: 5).
.EXAMPLE
    Start-PdfRenameWatcher -Path 'C:\Drop' -OpenAIKey $env:OPENAI_API_KEY
.EXAMPLE
    Start-PdfRenameWatcher -Path 'C:\Drop' -OpenAIKey $env:OPENAI_API_KEY -MaxFileSizeMB 50 -RetryCount 5
#>
function Start-PdfRenameWatcher {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OpenAIKey,

        [ValidateNotNullOrEmpty()]
        [string]$Model = 'gpt-4-1106-preview',

        [ValidateRange(1, 100)]
        [int]$MaxFileSizeMB = 25,

        [ValidateRange(1, 10)]
        [int]$RetryCount = 3,

        [ValidateRange(1, 60)]
        [int]$RetryDelaySeconds = 5
    )

    begin {
        # Import required modules
        $writeStatus = Join-Path -Path $PSScriptRoot -ChildPath '..\Write-Status.ps1'
        if (Test-Path $writeStatus) {
            . $writeStatus
        } else {
            # Fallback if Write-Status is not available
            function Write-Status { param($Level, $Message, [switch]$Fast) Write-Host "[$Level] $Message" }
        }

        # Initialize variables
        $script:Watcher = $null
        $script:EventJob = $null
        $script:IsRunning = $true
        $script:ProcessedFiles = @{}
        $script:MaxFileSizeBytes = $MaxFileSizeMB * 1MB
    }

    process {
        try {
            # Validate and resolve path
            if (-not (Test-Path $Path -PathType Container)) {
                Write-Status -Level ERROR -Message "Directory '$Path' not found or is not a directory."
                return
            }

            $resolved = (Resolve-Path $Path).Path
            Write-Status -Level INFO -Message "Resolved path: $resolved"

            # Test OpenAI connection
            if (-not (Test-OpenAIConnection -ApiKey $OpenAIKey)) {
                Write-Status -Level ERROR -Message "Failed to connect to OpenAI API. Please check your API key."
                return
            }

            # Setup file watcher
            $script:Watcher = New-Object System.IO.FileSystemWatcher $resolved, '*.pdf'
            $script:Watcher.IncludeSubdirectories = $false
            $script:Watcher.EnableRaisingEvents = $true
            $script:Watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName

            # Register event handler
            $script:EventJob = Register-ObjectEvent -InputObject $script:Watcher -EventName Created -SourceIdentifier PdfCreated -Action {
                param($source, $eventArgs)
                $file = $eventArgs.FullPath
                
                # Check if file is already being processed
                if ($script:ProcessedFiles.ContainsKey($file)) {
                    return
                }
                
                $script:ProcessedFiles[$file] = Get-Date
                
                try {
                    Invoke-PdfFileProcessing -FilePath $file -OpenAIKey $OpenAIKey -Model $Model -MaxFileSizeBytes $script:MaxFileSizeBytes -RetryCount $RetryCount -RetryDelaySeconds $RetryDelaySeconds
                }
                catch {
                    Write-Status -Level ERROR -Message "Error processing file '$file': $($_.Exception.Message)"
                }
                finally {
                    # Clean up processed file entry after 5 minutes
                    Start-Job -ScriptBlock {
                        param($file, $processedFiles)
                        Start-Sleep -Seconds 300
                        $processedFiles.Remove($file)
                    } -ArgumentList $file, $script:ProcessedFiles | Out-Null
                }
            }

            # Setup graceful shutdown
            $null = Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action {
                $script:IsRunning = $false
                Remove-Resources
            }

            Write-Status -Level SUCCESS -Message "PDF Rename Watcher started successfully"
            Write-Status -Level INFO -Message "Watching '$resolved' for PDF files (Max size: ${MaxFileSizeMB}MB)"
            Write-Status -Level INFO -Message "Press Ctrl+C to stop the watcher"

            # Main loop with graceful shutdown
            while ($script:IsRunning) {
                Start-Sleep -Seconds 1
                
                # Check for Ctrl+C
                if ([Console]::KeyAvailable) {
                    $key = [Console]::ReadKey($true)
                    if ($key.Modifiers -eq [ConsoleModifiers]::Control -and $key.Key -eq 'C') {
                        Write-Status -Level INFO -Message "Shutdown requested..."
                        break
                    }
                }
            }
        }
        catch {
            Write-Status -Level ERROR -Message "Fatal error: $($_.Exception.Message)"
        }
        finally {
            Remove-Resources
        }
    }
}

function Invoke-PdfFileProcessing {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string]$OpenAIKey,

        [string]$Model,

        [long]$MaxFileSizeBytes,

        [int]$RetryCount,

        [int]$RetryDelaySeconds
    )

    # Wait for file to be fully written
    Start-Sleep -Seconds 2

    # Validate file
    if (-not (Test-PdfFile -FilePath $FilePath -MaxFileSizeBytes $MaxFileSizeBytes)) {
        return
    }

    Write-Status -Level INFO -Message "Processing: $(Split-Path -Leaf $FilePath)"

    # Upload file with retry logic
    $fileId = Invoke-WithRetry -ScriptBlock {
        Send-OpenAIFile -Path $FilePath -ApiKey $OpenAIKey
    } -RetryCount $RetryCount -RetryDelaySeconds $RetryDelaySeconds -Operation "Upload"

    if (-not $fileId) {
        Write-Status -Level ERROR -Message "Failed to upload file after $RetryCount retries"
        return
    }

    try {
        # Get new filename with retry logic
        $newName = Invoke-WithRetry -ScriptBlock {
            Get-OpenAIPdfName -FileId $fileId -ApiKey $OpenAIKey -Model $Model
        } -RetryCount $RetryCount -RetryDelaySeconds $RetryDelaySeconds -Operation "Generate name"

        if (-not $newName) {
            Write-Status -Level ERROR -Message "Failed to generate filename after $RetryCount retries"
            return
        }

        # Clean and validate filename
        $cleanName = ConvertTo-CleanFileName -Name $newName
        if (-not $cleanName) {
            Write-Status -Level ERROR -Message "Generated filename is invalid or empty"
            return
        }

        # Generate unique filename if needed
        $finalName = New-UniqueFileName -BaseName $cleanName -Directory (Split-Path $FilePath -Parent)
        $destination = Join-Path -Path (Split-Path $FilePath -Parent) -ChildPath "$finalName.pdf"

        # Rename file
        Rename-Item -Path $FilePath -NewName $destination -ErrorAction Stop
        Write-Status -Level SUCCESS -Message "Renamed to: $(Split-Path -Leaf $destination)"
    }
    finally {
        # Clean up uploaded file from OpenAI
        Remove-OpenAIFile -FileId $fileId -ApiKey $OpenAIKey
    }
}

function Test-PdfFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [long]$MaxFileSizeBytes
    )

    if (-not (Test-Path $FilePath)) {
        Write-Status -Level WARNING -Message "File no longer exists: $(Split-Path -Leaf $FilePath)"
        return $false
    }

    $fileInfo = Get-Item $FilePath
    if ($fileInfo.Length -eq 0) {
        Write-Status -Level WARNING -Message "File is empty: $(Split-Path -Leaf $FilePath)"
        return $false
    }

    if ($fileInfo.Length -gt $MaxFileSizeBytes) {
        Write-Status -Level WARNING -Message "File too large ($([math]::Round($fileInfo.Length / 1MB, 2))MB): $(Split-Path -Leaf $FilePath)"
        return $false
    }

    return $true
}

function Test-OpenAIConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    try {
        $uri = 'https://api.openai.com/v1/models'
        $headers = @{ Authorization = "Bearer $ApiKey" }
        $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -TimeoutSec 10
        return $true
    }
    catch {
        Write-Status -Level ERROR -Message "OpenAI connection test failed: $($_.Exception.Message)"
        return $false
    }
}

function Send-OpenAIFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    try {
        $uri = 'https://api.openai.com/v1/files'
        $headers = @{ Authorization = "Bearer $ApiKey" }
        $form = @{ 
            file = Get-Item -Path $Path
            purpose = 'assistants' 
        }

        Write-Progress -Activity 'Uploading PDF to OpenAI' -Status (Split-Path -Leaf $Path) -PercentComplete 0
        $result = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Form $form -TimeoutSec 60
        Write-Progress -Activity 'Uploading PDF to OpenAI' -Completed

        return $result.id
    }
    catch {
        Write-Status -Level ERROR -Message "Upload failed: $($_.Exception.Message)"
        return $null
    }
}

function Get-OpenAIPdfName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FileId,

        [Parameter(Mandatory)]
        [string]$ApiKey,

        [string]$Model = 'gpt-4-1106-preview'
    )

    try {
        $uri = 'https://api.openai.com/v1/chat/completions'
        $headers = @{ Authorization = "Bearer $ApiKey" }
        $body = @{
            model = $Model
            messages = @(
                @{ 
                    role = 'system'
                    content = 'You are a helpful assistant that generates short, descriptive filenames for PDF documents. Return only the filename without extension. Keep it under 50 characters and use only alphanumeric characters, spaces, hyphens, and underscores. Make it descriptive but concise.'
                },
                @{ 
                    role = 'user'
                    content = 'Analyze the provided PDF and generate a descriptive filename based on its content, title, or subject matter.'
                }
            )
            file_ids = @($FileId)
            max_tokens = 20
            temperature = 0.3
        } | ConvertTo-Json -Depth 5

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -ContentType 'application/json' -Body $body -TimeoutSec 30
        return $response.choices[0].message.content.Trim()
    }
    catch {
        Write-Status -Level ERROR -Message "OpenAI request failed: $($_.Exception.Message)"
        return $null
    }
}

function Remove-OpenAIFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FileId,

        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    try {
        $uri = "https://api.openai.com/v1/files/$FileId"
        $headers = @{ Authorization = "Bearer $ApiKey" }
        Invoke-RestMethod -Uri $uri -Method Delete -Headers $headers -TimeoutSec 10 | Out-Null
    }
    catch {
        Write-Status -Level WARNING -Message "Failed to clean up uploaded file: $($_.Exception.Message)"
    }
}

function ConvertTo-CleanFileName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return $null
    }

    # Remove invalid characters
    $invalid = [System.IO.Path]::GetInvalidFileNameChars()
    foreach ($c in $invalid) {
        $Name = $Name -replace [Regex]::Escape($c), '-'
    }

    # Clean up multiple dashes and trim
    $Name = $Name -replace '-+', '-'
    $Name = $Name.Trim('-', ' ')

    # Ensure it's not empty after cleaning
    if ([string]::IsNullOrWhiteSpace($Name)) {
        return $null
    }

    return $Name
}

function New-UniqueFileName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$BaseName,

        [Parameter(Mandatory)]
        [string]$Directory
    )

    $counter = 1
    $fileName = $BaseName
    $fullPath = Join-Path -Path $Directory -ChildPath "$fileName.pdf"

    while (Test-Path $fullPath) {
        $fileName = "${BaseName}_$counter"
        $fullPath = Join-Path -Path $Directory -ChildPath "$fileName.pdf"
        $counter++
    }

    return $fileName
}

function Invoke-WithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,

        [int]$RetryCount = 3,

        [int]$RetryDelaySeconds = 5,

        [string]$Operation = "Operation"
    )

    for ($i = 1; $i -le $RetryCount; $i++) {
        try {
            $result = & $ScriptBlock
            if ($result) {
                return $result
            }
        }
        catch {
            if ($i -eq $RetryCount) {
                Write-Status -Level ERROR -Message "$Operation failed after $RetryCount attempts: $($_.Exception.Message)"
                return $null
            }
            Write-Status -Level WARNING -Message "$Operation attempt $i failed, retrying in $RetryDelaySeconds seconds..."
            Start-Sleep -Seconds $RetryDelaySeconds
        }
    }

    return $null
}

function Remove-Resources {
    if ($script:EventJob) {
        Unregister-Event -SourceIdentifier PdfCreated -ErrorAction SilentlyContinue
        Remove-Job -Name PdfCreated -ErrorAction SilentlyContinue
        $script:EventJob = $null
    }

    if ($script:Watcher) {
        $script:Watcher.EnableRaisingEvents = $false
        $script:Watcher.Dispose()
        $script:Watcher = $null
    }

    Write-Status -Level INFO -Message "PDF Rename Watcher stopped"
}

# Entry point for direct execution
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Start-PdfRenameWatcher @PSBoundParameters
}
