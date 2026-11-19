import { handleFoodAnalysis } from './handler.ts';

Deno.serve((req) => handleFoodAnalysis(req));
