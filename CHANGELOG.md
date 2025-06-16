# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Added additional Pester tests for dependency checking functions.
- Added AGENTS guidelines and modular TypeScript agent framework ([PR #1](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/1), [PR #4](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/4)).
- Introduced Write-Status logging utilities and dependency checking script with Pester tests ([PR #8](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/8), [PR #9](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/9), [PR #21](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/21)).
- Expanded documentation with PowerShell guidelines and repository structure details ([PR #12](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/12), [PR #15](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/15)).
- Added `Install-ZTools` script to load all modules and optionally run a configuration script.
- Added `Configure-SharePoint` script to save tenant and app credentials in Credential Manager.
- Added GitHub workflows for Pester tests and automated documentation generation ([PR #18](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/18), [PR #19](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/19), [PR #20](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/20)).
- Documented modular architecture and system requirements ([PR #22](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/22)).
- Enabled JaCoCo code coverage for Pester tests via `.pester.ps1`.
- Updated CI workflow to include code coverage results for Pester tests.
- Fixed Pester execution in GitHub Actions by relying on configuration instead of the `-CI` parameter.
- Initial repository setup with basic PowerShell tooling structure ([PR #2](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/2), [PR #3](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/3)).
- Documented changelog update process to remove timestamp and PR link requirement
- Updated AGENTS guidelines to drop timestamp and PR link requirement for changelog entries
- Added ZtCore orchestrator and domain module folders with initial README files.
- Clarified API roadmap in AGENTS.md [2025-06-16 02:18 UTC](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools/pull/??)
- Added guidance to display progress bars for long-running tasks in AGENTS.md.
- Added ZtEntity base class for cross-module data exchange.
