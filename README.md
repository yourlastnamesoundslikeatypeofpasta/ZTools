# ZTools

ZTools is a collection of PowerShell utilities and experimental TypeScript agents used for automation tasks. The repository is currently a skeleton that will be populated with organized tools over time.

## Project Goals

- Provide a central location for PowerShell scripts used in administrative and automation tasks.
- Organize scripts in a clear directory structure for easier maintenance.
- Document usage so that anyone on the team can leverage these tools.

## Repository Structure

```
ZTools/
├── src/           # PowerShell scripts and modules
├── agents/        # TypeScript agent scripts
├── scripts/       # Helper PowerShell scripts
├── docs/          # Additional documentation
├── tests/         # Pester tests
├── AGENTS.md      # Contribution guidelines
├── CHANGELOG.md   # Release history
├── LICENSE        # MIT License
└── README.md      # Project documentation
```

*This layout may evolve as more tools are added.*
The `agents/` folder hosts TypeScript code, `src/` is reserved for PowerShell utilities, `scripts/` contains automation helpers, and `tests/` holds Pester tests.

## Prerequisites

- Windows PowerShell 5.1 or [PowerShell](https://github.com/PowerShell/PowerShell) 7+
- [Node.js](https://nodejs.org/) for running the TypeScript agents

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd ZTools
   ```
2. **Browse the tools**
   - PowerShell scripts are under `src/`
   - TypeScript agents are under `agents/`

## PowerShell Best Practices

- Use comment-based help in each script so usage is clear.
- Follow verb-noun naming for all functions.
- Validate parameters with `[CmdletBinding()]` and `param` blocks.
- Prefer logging via `Write-Verbose`/`Write-Error` instead of `Write-Host`.
- Avoid hard-coded paths and accept them as parameters.

For more detail see [PowerShell Guidelines](docs/PowerShell-Guidelines.md).

## Write-Status Logging Utility

`Write-Status` standardizes messaging across scripts. It honors PowerShell
preference variables and logs every entry to a file.

```powershell
# Basic usage
Write-Status -Level INFO -Message 'Starting build'

# Redirect logs
Write-Status -Level WARN -Message 'Low disk space' -LogFile 'C:\temp\build.log'

# Pipeline support
'Finished' | Write-Status -Level SUCCESS -Fast
```

`Write-Status` maps levels to `Write-Verbose`, `Write-Warning`, `Write-Error` or
`Write-Debug`, so built-in switches like `-Verbose` control console output.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request with improvements or new scripts. Please include documentation for any new tools.
Refer to `AGENTS.md` and `docs/PowerShell_Guidelines.md` for naming conventions and pipeline support when adding new PowerShell scripts.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

