This repository contains PowerShell utilities and a set of experimental TypeScript agents.
The project is hosted at [https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools](https://github.com/yourlastnamesoundslikeatypeofpasta/ZTools).

## Architecture
- Build every cmdlet and agent as a modular component so the project scales easily.
- Use a shared base data structure for cross-module communication and orchestration.
- Keep modules interoperable; pipeline output from one module should integrate with others.
- Implement comprehensive logging with multiple output streams and a rich format.
- Display a progress bar during long-running tasks. Use `Write-Progress` or similar tools to show Windows-style progress updates where practical.
- Handle failures gracefully with `try/catch` blocks and fallback logic.
- Secure configuration using PowerShell credential management and sign scripts when possible.
- Unit test new features after implementation to maintain reliability.

## Module Development Roadmap

The project is organized into discrete modules that can be combined through an
orchestrator. Current module folders under `src/` include:

- `ActiveDirectory`
- `ExchangeOnline`
- `MicrosoftGraph`
- `PnP`
- `MonitoringTools` - scripts to read CPU, memory, disk and domain information
- `ZtCore` (orchestrator)

Develop each module with consistent input and output structures so that they can
be surfaced later through RESTful API endpoints. The orchestrator module will be
responsible for coordinating these modules and exposing toolbox features.

The long‑term goal is to provide an API layer that allows both read and write
operations via HTTP routes. Design functions with this future API integration in
mind so they can be easily imported or invoked by a custom GPT or other
interfaces.

## PowerShell scripts
- Keep all PowerShell code under the `src/` directory using the `.ps1` extension.
- Include comment-based help for any new scripts and ensure each function supports `-Verbose` and `-ErrorAction`.
- Use advanced functions with `[CmdletBinding()]` and a `param()` block.
- Support pipeline input where practical.
- Follow the naming conventions in `docs/PowerShell_Guidelines.md`.
- Keep simple functions as one-shot scripts without `Begin`, `Process`, or `End` blocks.
- Use `Begin`, `Process`, and `End` sections only when pipeline input or distinct setup and cleanup phases are required.

## TypeScript agents
- Place TypeScript files inside the `agents/` directory using the `.ts` extension.
- Document new or updated agents in `agents/AGENT_ROLES.md`.
 - Run the agents using your preferred workflow (for example `ts-node`). Currently no automated tests exist for this code.

The repository uses Pester for testing PowerShell scripts. Before running any tests or scripts, execute `src/Check-Dependencies.ps1` to confirm required modules are available. If any tests exist under the `tests/` directory, run them with `pwsh -Command "Invoke-Pester -Configuration (./.pester.ps1)"` before committing so coverage results are generated. If Pester is not installed, install it via PowerShell's `Install-Module -Name Pester -Force`.

Pull request summaries should mention notable changes and reference any tests run.

## Changelog updates

`CHANGELOG.md` is automatically generated from merged pull requests.
Do not edit it manually in individual PRs.

## Dependencies

Most tools rely on several PowerShell modules. Ensure the following modules are installed:

- `PnP.PowerShell`
- `ExchangeOnlineManagement`
- `Microsoft.Graph`
- `ActiveDirectory` (requires RSAT tools)

Run `src/Check-Dependencies.ps1` before running tests or scripts to verify that your environment meets these requirements.

## Background Thread Jobs

**When to apply**
- Any time an agent needs to run a quick, non-blocking PowerShell task (e.g. file enumeration, simple API calls, folder scans) without the overhead of a separate PowerShell process.

**Pattern**
- Use the built-in `ThreadJob` module and `Start-ThreadJob` cmdlet
- Pass input via `-ArgumentList` and declare parameters inside the script block.

**Example Snippet**
```powershell
# 1. Define your input
$path = "C:\Logs"

# 2. Launch a lightweight background thread
Start-ThreadJob -ScriptBlock {
    param($targetPath)
    # Recursively list everything under the given path
    Get-ChildItem -Path $targetPath -Recurse
} -ArgumentList $path

# 3. (Later) Wait for and retrieve results
$job = Get-Job | Where Name -eq ThreadJob  # or capture the returned job
$job | Wait-Job
$items = $job | Receive-Job
```

## Release process

- Use [Semantic Versioning](https://semver.org/) for all modules.
- Each module should have a `.psd1` manifest with `ModuleVersion` starting at `0.1.0`.
- Include a `.VERSION` tag in comment-based help for each function.
- Increment the major version for breaking changes, minor for new features, and patch for fixes.
- Bump versions in the same pull request that introduces the change and ensure the PR description reflects these updates.
- `CHANGELOG.md` is generated from pull request titles, so keep them descriptive.
- After merging to `main`, tag the repository with the module version to mark the release.
