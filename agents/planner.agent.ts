/**
 * Planner Agent
 * --------------
 * Role: Breaks a user task into manageable subtasks.
 * Input: { task: string }
 * Output: { subtasks: string[]; nextAgent: string }
 */
export interface PlannerInput {
  task: string;
}

export interface PlannerOutput {
  subtasks: string[];
  nextAgent: string;
}

export function runPlanner(input: PlannerInput): PlannerOutput {
  const subtasks = input.task.split('.').map(t => t.trim()).filter(t => t.length);
  return {
    subtasks,
    nextAgent: 'searcher'
  };
}
