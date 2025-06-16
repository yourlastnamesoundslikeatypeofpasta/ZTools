# PowerShell Guidelines

This document outlines conventions and recommended practices for PowerShell scripts in this repository.

## Recommended Practices

- **Use comment-based help** so each script includes a `.SYNOPSIS`, `.DESCRIPTION` and examples.
- **Adopt verb-noun naming** for all functions to follow the PowerShell standard command pattern.
- **Implement functions with `[CmdletBinding()]` and a `param()` block**. Support common switches like `-WhatIf` and `-Verbose`.
- **Validate parameters** to enforce correct usage.
- **Prefer structured logging** with `Write-Verbose`, `Write-Warning` and `Write-Error` instead of `Write-Host`.
- **Avoid hard-coded paths**; accept them as parameters or derive them dynamically for portability.
- **Allow pipeline input** using `ValueFromPipeline` or `ValueFromPipelineByPropertyName` where practical.
- **Process items in the `process` block** to handle streaming data correctly.

## Naming conventions

- Use the `Verb-Noun` pattern with [approved PowerShell verbs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Verbs).
- Use PascalCase for both the verb and noun parts (for example, `Get-ItemInfo`).

Follow these guidelines and include comment-based help when adding new scripts.
