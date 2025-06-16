# PowerShell Guidelines

This document outlines recommended practices when writing PowerShell scripts for the ZTools repository.

## Recommended Practices

- **Use comment-based help** so that each script includes a `.SYNOPSIS`, `.DESCRIPTION`, and examples.
- **Adopt verb-noun naming** for all functions to follow the PowerShell standard command pattern.
- **Validate parameters** with `[CmdletBinding()]` and `param` blocks to enforce correct usage.
- **Prefer structured logging** with `Write-Verbose`, `Write-Warning`, and `Write-Error` rather than `Write-Host`.
- **Avoid hard-coded paths**; accept paths as parameters or derive them dynamically for portability.

Following these guidelines keeps the scripts consistent and maintainable.
