/**
 * Coder Agent
 * -----------
 * Role: Generates placeholder code based on instructions.
 * Input: { instructions: string }
 * Output: { code: string; nextAgent: string }
 */
export interface CoderInput {
  instructions: string;
}

export interface CoderOutput {
  code: string;
  nextAgent: string;
}

export function runCoder(input: CoderInput): CoderOutput {
  // Sanitize backticks to avoid breaking template literals
  const instructions = input.instructions.replace(/`/g, '\\`');

  const code = `
<#
.SYNOPSIS
Generated PowerShell script skeleton.

.DESCRIPTION
${instructions}
#>

function Invoke-GeneratedTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ExampleParam
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    try {
        # TODO: Implement logic
    }
    catch {
        Write-Error "An unexpected error occurred: $_"
        throw
    }
    finally {
        # TODO: Add cleanup code if necessary
    }
}
`;

  return {
    code,
    nextAgent: 'reviewer'
  };
}
