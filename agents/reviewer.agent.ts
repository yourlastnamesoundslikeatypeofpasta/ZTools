/**
 * Reviewer Agent
 * --------------
 * Role: Reviews generated code and provides comments.
 * Input: { code: string }
 * Output: { comments: string }
 */
export interface ReviewerInput {
  code: string;
}

export interface ReviewerOutput {
  comments: string;
}

export function runReviewer(input: ReviewerInput): ReviewerOutput {
  const comments = input.code.includes('TODO')
    ? 'Code contains TODOs. Needs implementation.'
    : 'Looks good.';
  return { comments };
}
