/**
 * Searcher Agent
 * --------------
 * Role: Performs a simulated search based on a query.
 * Input: { query: string }
 * Output: { results: string; nextAgent: string }
 */
export interface SearcherInput {
  query: string;
}

export interface SearcherOutput {
  results: string;
  nextAgent: string;
}

export function runSearcher(input: SearcherInput): SearcherOutput {
  const results = `Results for: ${input.query}`;
  return {
    results,
    nextAgent: 'coder'
  };
}
