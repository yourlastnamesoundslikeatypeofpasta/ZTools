# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Updated MonitoringTools tests for Windows compatibility.
- Added additional Pester tests for dependency checking functions. (PR #41)
- Updated Test-RequiredModules to run module checks in parallel using thread jobs and added new tests. (PR #)
- Added Set-WriteStatusConfig to customize logging paths and updated README with examples. (PR #)
- Updated Pester CI workflow to run on all pull requests. (PR #44)
- Added AGENTS guidelines and modular TypeScript agent framework (PR #1, PR #4).
- Introduced Write-Status logging utilities and dependency checking script with Pester tests (PR #8, PR #9, PR #21).
- Expanded documentation with PowerShell guidelines and repository structure details (PR #12, PR #15).
- Added `Install-ZTools` script to load all modules and optionally run a configuration script. (PR #42)
- Added `Configure-SharePoint` script to save tenant and app credentials in Credential Manager. (PR #43)
- Added GitHub workflows for Pester tests and automated documentation generation (PR #18, PR #19, PR #20).
- Added `ZTools` module manifest and module file for future cmdlet development. (PR #)
- Documented modular architecture and system requirements (PR #22).
- Enabled JaCoCo code coverage for Pester tests via `.pester.ps1`. (PR #28)
- Updated CI workflow to include code coverage results for Pester tests. (PR #30)
- Fixed Pester execution in GitHub Actions by relying on configuration instead of the `-CI` parameter. (PR #37)
- Removed pipeline input support from Write-Status and updated tests and documentation. (PR #)
- Initial repository setup with basic PowerShell tooling structure (PR #2, PR #3).
- Documented changelog update process to remove timestamp and PR link requirement (PR #33)
- Updated AGENTS guidelines to drop timestamp and PR link requirement for changelog entries (PR #33)
- Added `Set-ComputerIPAddress` support tool to configure a static IP address directly. (PR #)
- Added ZtCore orchestrator and domain module folders with initial README files. (PR #29)
- Clarified API roadmap in AGENTS.md (PR #35)
- Added guidance to display progress bars for long-running tasks in AGENTS.md. (PR #36)
- Added ZtEntity base class for cross-module data exchange. (PR #40)
- Added Pester tests for Set-SharePointConfig, Install-ZTools configuration script handling and ZtEntity. (PR #45)
- Added EntraID module with functions to query Microsoft Graph and return `ZtEntity` objects. (PR #48)
- Documented Start-ThreadJob usage for background tasks in AGENTS.md. (PR #47)
- Added `Export-ProductKey` function to retrieve the Windows product key. (PR #49)
- Documented leaving the pull request number blank and appending entries to the end of the changelog in AGENTS instructions. (PR #)
- Moved `Check-Dependencies` script under `src` and updated references. (PR #)
- Removed duplicate `PowerShell-Guidelines.md` and updated references. (PR #)
- Updated `Install-ZTools` to load module files using a background thread and moved the ThreadJob import. (PR #)
- Added comment-based help to `Check-Dependencies.ps1` script. (PR #)
- Verified cleanup of old `docs/PowerShell-Guidelines.md` references. (PR #)
- Enhanced `Set-ComputerIPAddress` with error handling, pipeline input and administrator validation. (PR #)
- Added shared Test-IsAdministrator function for elevation checks. (PR #)
- Added PowerShell_References document with links to key module documentation. (PR #)
- Clarified PowerShell function guidelines in `AGENTS.md`, including when to use
  `Begin`, `Process`, and `End` blocks. (PR #)
- Restored composite GitHub Action and README markers for automatic documentation. (PR #)
- Removed auto documentation workflow and composite action file. (PR #)
- Updated Write-Status to use '>' for INFO messages and adjusted tests. (PR #)
- Documented repository URL in README clone instructions. (PR #)
- Added more Pester tests for MonitoringTools functions. (PR #)
- Instructed contributors to run `src/Check-Dependencies.ps1` before running tests or scripts. (PR #)
- Removed duplicate bullet about API layer from Architecture section in AGENTS guidelines. (PR #)
- Documented running Pester tests with the repository configuration in AGENTS guidelines. (PR #)
