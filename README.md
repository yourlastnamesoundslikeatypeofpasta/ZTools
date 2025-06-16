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
├── AGENTS.md      # Contribution guidelines
├── LICENSE        # MIT License
└── README.md      # Project documentation
```

*This layout may evolve as more tools are added.*
The `agents/` folder hosts TypeScript code while `src/` is reserved for PowerShell utilities.

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

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request with improvements or new scripts. Please include documentation for any new tools.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

