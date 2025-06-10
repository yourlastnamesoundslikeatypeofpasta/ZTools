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
  const code = `// TODO: Implement\n// Instructions: ${input.instructions}`;
  return {
    code,
    nextAgent: 'reviewer'
  };
}
