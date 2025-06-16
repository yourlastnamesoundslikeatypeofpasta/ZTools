# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Added additional Pester tests for dependency checking functions. (PR #41)
- Updated Pester CI workflow to run on all pull requests. (PR #44)
- Added AGENTS guidelines and modular TypeScript agent framework (PR #1, PR #4).
- Introduced Write-Status logging utilities and dependency checking script with Pester tests (PR #8, PR #9, PR #21).
- Expanded documentation with PowerShell guidelines and repository structure details (PR #12, PR #15).
- Added `Install-ZTools` script to load all modules and optionally run a configuration script. (PR #42)
- Added `Configure-SharePoint` script to save tenant and app credentials in Credential Manager. (PR #43)
- Added GitHub workflows for Pester tests and automated documentation generation (PR #18, PR #19, PR #20).
- Documented modular architecture and system requirements (PR #22).
- Enabled JaCoCo code coverage for Pester tests via `.pester.ps1`. (PR #28)
- Updated CI workflow to include code coverage results for Pester tests. (PR #30)
- Fixed Pester execution in GitHub Actions by relying on configuration instead of the `-CI` parameter. (PR #37)
- Initial repository setup with basic PowerShell tooling structure (PR #2, PR #3).
- Documented changelog update process to remove timestamp and PR link requirement (PR #33)
- Updated AGENTS guidelines to drop timestamp and PR link requirement for changelog entries (PR #33)
- Added ZtCore orchestrator and domain module folders with initial README files. (PR #29)
- Clarified API roadmap in AGENTS.md (PR #35)
- Added guidance to display progress bars for long-running tasks in AGENTS.md. (PR #36)
- Added ZtEntity base class for cross-module data exchange. (PR #40)
- Added Pester tests for Set-SharePointConfig, Install-ZTools configuration script handling and ZtEntity. (PR #45)
- Added EntraID module with functions to query Microsoft Graph and return `ZtEntity` objects. (PR #48)
- Documented Start-ThreadJob usage for background tasks in AGENTS.md. (PR #47)
- Added `Export-ProductKey` function to retrieve the Windows product key. (PR #49)
- Consolidated PowerShell guidelines and updated documentation references. (PR #50)
