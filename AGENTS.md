This repository contains PowerShell utilities and a set of experimental TypeScript agents.

## PowerShell scripts
- Keep all PowerShell code under the `src/` directory using the `.ps1` extension.
- Include comment-based help for any new scripts.
- Use advanced functions with `[CmdletBinding()]` and a `param()` block.
- Support pipeline input where practical.
- Follow the naming conventions in `docs/PowerShell_Guidelines.md`.

## TypeScript agents
- Place TypeScript files inside the `agents/` directory using the `.ts` extension.
- Document new or updated agents in `agents/AGENT_ROLES.md`.
- Run the agents using your preferred Node.js workflow (for example `ts-node`). Currently no automated tests exist for this code.

The repository uses Pester for testing PowerShell scripts. If any tests exist under the `tests/` directory, run them with `pwsh -Command Invoke-Pester` before committing. If Pester is not installed, install it via PowerShell's `Install-Module -Name Pester -Force`.

Pull request summaries should mention notable changes and reference any tests run.
