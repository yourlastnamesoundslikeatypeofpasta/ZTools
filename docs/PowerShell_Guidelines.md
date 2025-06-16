# PowerShell Guidelines

This document outlines conventions for PowerShell scripts in this repository.

## Advanced functions
- Implement functions using `[CmdletBinding()]` and a `param()` block.
- Support common features like `-WhatIf` and `-Verbose` through `CmdletBinding`.

## Pipeline support
- Where practical, allow pipeline input by using `ValueFromPipeline` or `ValueFromPipelineByPropertyName` on parameters.
- Process items in the `process` block to handle streaming data correctly.

## Naming conventions
- Use the `Verb-Noun` pattern with [approved PowerShell verbs](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Verbs).
- Use PascalCase for both the verb and noun parts (for example, `Get-ItemInfo`).

Follow these guidelines and include comment-based help when adding new scripts.
