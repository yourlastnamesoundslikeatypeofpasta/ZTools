<#
.SYNOPSIS
    Watches a folder for new PDF files and renames them using OpenAI.
.DESCRIPTION
    Creates a FileSystemWatcher on the target folder. When a PDF file is dropped
    into the directory, the document is uploaded to the OpenAI API and a short
    descriptive name is requested. The file is then renamed to the suggested
    name.
.PARAMETER Path
    Folder path to monitor for PDF files.
.PARAMETER OpenAIKey
    API key used when calling the OpenAI service.
.PARAMETER Model
    Optional model name for the chat completion request.
.EXAMPLE
    Start-PdfRenameWatcher -Path 'C:\Drop' -OpenAIKey $env:OPENAI_API_KEY
#>
function Start-PdfRenameWatcher {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$OpenAIKey,

        [string]$Model = 'gpt-4-1106-preview'
    )

    begin {
        $writeStatus = Join-Path -Path $PSScriptRoot -ChildPath '..\Write-Status.ps1'
        . $writeStatus
    }

    process {
        if (-not (Test-Path $Path)) {
            Write-Status -Level ERROR -Message "Directory '$Path' not found."
            return
        }

        $resolved = (Resolve-Path $Path).Path
        $watcher = New-Object System.IO.FileSystemWatcher $resolved, '*.pdf'
        $watcher.IncludeSubdirectories = $false
        $watcher.EnableRaisingEvents = $true

        Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier PdfCreated -Action {
            param($source, $eventArgs)
            $file = $eventArgs.FullPath
            Start-Sleep -Seconds 1
            Write-Status -Level INFO -Message "Uploading $(Split-Path -Leaf $file)" -Fast
            $id = Upload-OpenAIFile -Path $file -ApiKey $OpenAIKey
            if (-not $id) { return }

            Write-Status -Level INFO -Message 'Requesting new file name' -Fast
            $name = Get-OpenAIPdfName -FileId $id -ApiKey $OpenAIKey -Model $Model
            if (-not $name) { return }

            $invalid = [System.IO.Path]::GetInvalidFileNameChars()
            foreach ($c in $invalid) { $name = $name -replace [Regex]::Escape($c), '-' }
            $destination = Join-Path -Path (Split-Path $file -Parent) -ChildPath "$name.pdf"

            try {
                Rename-Item -Path $file -NewName $destination -ErrorAction Stop
                Write-Status -Level SUCCESS -Message "Renamed to $(Split-Path -Leaf $destination)" -Fast
            } catch {
                Write-Status -Level ERROR -Message $_.Exception.Message
            }
        }

        Write-Status -Level INFO -Message "Watching '$resolved' for PDF files. Press Ctrl+C to stop."
        while ($true) { Start-Sleep -Seconds 5 }
    }
}

function Upload-OpenAIFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [string]$ApiKey
    )
    process {
        try {
            $uri = 'https://api.openai.com/v1/files'
            $headers = @{ Authorization = "Bearer $ApiKey" }
            $form = @{ file = Get-Item -Path $Path; purpose = 'assistants' }
            Write-Progress -Activity 'Uploading PDF to OpenAI' -Status (Split-Path -Leaf $Path) -PercentComplete 0
            $result = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Form $form
            Write-Progress -Activity 'Uploading PDF to OpenAI' -Completed
            return $result.id
        } catch {
            Write-Status -Level ERROR -Message "Upload failed: $_"
        }
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
    process {
        try {
            $uri = 'https://api.openai.com/v1/chat/completions'
            $headers = @{ Authorization = "Bearer $ApiKey" }
            $body = @{
                model = $Model
                messages = @(
                    @{ role = 'system'; content = 'Provide a short descriptive filename based on the uploaded PDF. Return only the filename without extension.' },
                    @{ role = 'user'; content = 'Use the provided PDF to generate a name.' }
                )
                file_ids = @($FileId)
                max_tokens = 10
            } | ConvertTo-Json -Depth 5
            $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -ContentType 'application/json' -Body $body
            return $response.choices[0].message.content.Trim()
        } catch {
            Write-Status -Level ERROR -Message "OpenAI request failed: $_"
        }
    }
}

# Entry point for direct execution
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Start-PdfRenameWatcher @PSBoundParameters
}
