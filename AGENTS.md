This repository contains PowerShell utilities. All code should be under the `src/` directory using the `.ps1` extension. When adding new scripts, include comment-based help.

The repository uses Pester for testing. If any tests exist under the `tests/` directory, run them with `pwsh -Command Invoke-Pester` before committing. If Pester is not installed, install it via PowerShell's `Install-Module -Name Pester -Force`.

Pull request summaries should mention notable changes and reference any tests run.
