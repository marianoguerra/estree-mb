// Shared helpers for comparing ESTree ASTs produced by different parsers.
import * as acorn from "acorn";
import { parseSync } from "oxc-parser";

export { astDiff, firstDiff, jsonReplacer, normalize } from "./ast_diff.mjs";

// acorn is the strict oracle (it also checks module-level semantics such as
// undeclared exports); oxc is used for stage 3 syntax acorn cannot parse.
export function parseAcorn(code, sourceType) {
  return acorn.parse(code, { ecmaVersion: "latest", sourceType, locations: true, ranges: true });
}

export function parseOxc(code, sourceType) {
  const result = parseSync(sourceType === "script" ? "input.cjs" : "input.mjs", code, {
    sourceType,
    preserveParens: false,
  });
  if (result.errors.length > 0) {
    throw new SyntaxError(result.errors.map((e) => e.message).join("; "));
  }
  return result.program;
}

export const usesStage3 = (name) => name.startsWith("stage3_");

// Parses `code` with the oracle suited to fixture `name`.
export function reparse(name, code, sourceType) {
  return usesStage3(name) ? parseOxc(code, sourceType) : parseAcorn(code, sourceType);
}
