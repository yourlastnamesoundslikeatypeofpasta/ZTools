/**
 * Agent Engine
 * ------------
 * Role: Orchestrates agents from planner to reviewer.
 * Input: { task: string }
 * Output: {
 *   subtasks: string[];
 *   findings: string;
 *   code: string;
 *   review: string;
 * }
 */
import { runPlanner } from './planner.agent';
import { runSearcher } from './searcher.agent';
import { runCoder } from './coder.agent';
import { runReviewer } from './reviewer.agent';

export interface EngineInput {
  task: string;
}

export interface EngineOutput {
  subtasks: string[];
  findings: string;
  code: string;
  review: string;
}

export function runAgentEngine(input: EngineInput): EngineOutput {
  const planner = runPlanner({ task: input.task });
  const searcher = runSearcher({ query: planner.subtasks.join(' ') });
  const coder = runCoder({ instructions: searcher.results });
  const reviewer = runReviewer({ code: coder.code });
  return {
    subtasks: planner.subtasks,
    findings: searcher.results,
    code: coder.code,
    review: reviewer.comments
  };
}
