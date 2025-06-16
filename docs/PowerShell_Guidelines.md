# PowerShell Guidelines

This document outlines recommended practices when writing PowerShell scripts in this repository.

## General Recommendations
- Use comment-based help so each script includes a `.SYNOPSIS`, `.DESCRIPTION` and examples.
- Prefer structured logging with `Write-Verbose`, `Write-Warning` and `Write-Error` rather than `Write-Host`.
- Avoid hard-coded paths; accept them as parameters or derive them dynamically.

## Advanced Functions
- Implement functions using `[CmdletBinding()]` and a `param()` block.
- Validate parameters in the `param` block and support common features like `-WhatIf` and `-Verbose`.

## Pipeline Support
- Where practical, allow pipeline input using `ValueFromPipeline` or `ValueFromPipelineByPropertyName` on parameters.
- Process items in the `process` block to handle streaming data correctly.

## Naming Conventions
- Use the `Verb-Noun` pattern with [approved PowerShell verbs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Verbs).
- Use PascalCase for both the verb and noun parts (for example, `Get-ItemInfo`).

Follow these guidelines and include comment-based help when adding new scripts.
