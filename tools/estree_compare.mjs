// Shared helpers for comparing ESTree ASTs produced by different parsers.
import * as acorn from "acorn";
import { parseSync } from "oxc-parser";

const POSITION_KEYS = new Set(["start", "end", "loc", "range"]);

// RegExp and BigInt literal values have no JSON form; ESTree consumers rely on
// `regex` / `bigint` instead, so they serialize as `null`.
export const jsonReplacer = (_key, value) =>
  typeof value === "bigint" || value instanceof RegExp ? null : value;

// Strips positions and the parser-specific spellings of "absent" so that
// acorn, oxc and our canonical JSON compare equal.
export function normalize(node) {
  if (Array.isArray(node)) return node.map(normalize);
  if (node === null || typeof node !== "object") return node;
  if (typeof node === "bigint" || node instanceof RegExp) return null;
  const out = {};
  for (const [key, value] of Object.entries(node)) {
    if (POSITION_KEYS.has(key)) continue;
    if (key === "decorators" && Array.isArray(value) && value.length === 0) continue;
    if (key === "phase" && value === null) continue;
    if (node.type === "Program" && (key === "hashbang" || key === "comments")) continue;
    out[key] = normalize(value);
  }
  return out;
}

// Returns a description of the first difference between two normalized ASTs,
// or null when they are equal.
export function firstDiff(a, b, path = "$") {
  if (Array.isArray(a) !== Array.isArray(b) || typeof a !== typeof b) {
    return `${path}: ${show(a)} vs ${show(b)}`;
  }
  if (a !== null && typeof a === "object") {
    for (const key of new Set([...Object.keys(a), ...Object.keys(b ?? {})])) {
      const diff = firstDiff(a[key], b?.[key], `${path}.${key}`);
      if (diff) return diff;
    }
    return null;
  }
  return Object.is(a, b) || a === b ? null : `${path}: ${show(a)} vs ${show(b)}`;
}

const show = (v) => (JSON.stringify(v) ?? String(v)).slice(0, 100);

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

// Normalized comparison of `expected` (an ESTree JSON value) with `actual`.
export function astDiff(expected, actual) {
  return firstDiff(normalize(expected), normalize(JSON.parse(JSON.stringify(actual, jsonReplacer))));
}
