/**
 * Router Agent
 * ------------
 * Role: Determines which agent should handle a task.
 * Input: { task: string, context?: any }
 * Output: { nextAgent: string; reason: string }
 */
export interface RouterInput {
  task: string;
  context?: any;
}

export interface RouterOutput {
  nextAgent: string;
  reason: string;
}

export function runRouter(input: RouterInput): RouterOutput {
  const task = input.task.toLowerCase();
  let nextAgent = 'planner';
  let reason = 'Default to planner for task breakdown.';

  if (/search|find/.test(task)) {
    nextAgent = 'searcher';
    reason = 'Task involves searching for information.';
  } else if (/code|implement|script|write/.test(task)) {
    nextAgent = 'coder';
    reason = 'Task requires code generation.';
  } else if (/review|feedback|analyze/.test(task)) {
    nextAgent = 'reviewer';
    reason = 'Task requests code review or analysis.';
  }

  return { nextAgent, reason };
}
