# Agent Roles

| Agent | Description | Input | Output |
|-------|-------------|-------|--------|
| planner.agent.ts | Breaks a user task into subtasks. | `{ task: string }` | `{ subtasks: string[]; nextAgent: string }` |
| searcher.agent.ts | Performs a simulated search based on subtasks. | `{ query: string }` | `{ results: string; nextAgent: string }` |
| coder.agent.ts | Generates placeholder code from instructions. | `{ instructions: string }` | `{ code: string; nextAgent: string }` |
| reviewer.agent.ts | Reviews generated code and provides feedback. | `{ code: string }` | `{ comments: string }` |
| router.agent.ts | Determines the next agent to handle a task. | `{ task: string, context?: any }` | `{ nextAgent: string; reason: string }` |
| agent.engine.ts | Orchestrates all agents from planning to review. | `{ task: string }` | `{ subtasks: string[]; findings: string; code: string; review: string }` |
