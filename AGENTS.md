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
- Plan for an API layer so these tools can be accessed by web or GPT-based clients.

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
- Include comment-based help for any new scripts.
- Use advanced functions with `[CmdletBinding()]` and a `param()` block.
- Support pipeline input where practical.
- Follow the naming conventions in `docs/PowerShell_Guidelines.md`.

## TypeScript agents
- Place TypeScript files inside the `agents/` directory using the `.ts` extension.
- Document new or updated agents in `agents/AGENT_ROLES.md`.
 - Run the agents using your preferred workflow (for example `ts-node`). Currently no automated tests exist for this code.

The repository uses Pester for testing PowerShell scripts. If any tests exist under the `tests/` directory, run them with `pwsh -Command Invoke-Pester` before committing. If Pester is not installed, install it via PowerShell's `Install-Module -Name Pester -Force`.

Pull request summaries should mention notable changes and reference any tests run.

## Changelog updates

- Update `CHANGELOG.md` in every pull request.
- Add a bullet under the `Unreleased` section describing the change.
- Do **not** include a timestamp or link to the pull request.
- The changelog can be updated again after the pull request is merged if needed.

## Dependencies

Most tools rely on several PowerShell modules. Ensure the following modules are installed:

- `PnP.PowerShell`
- `ExchangeOnlineManagement`
- `Microsoft.Graph`
- `ActiveDirectory` (requires RSAT tools)

Run `scripts/Check-Dependencies.ps1` to verify that your environment meets these requirements.
