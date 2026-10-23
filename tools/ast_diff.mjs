// Parser-independent helpers for comparing ESTree ASTs. Has no Node or
// parser imports so the playground (site/) can load it in the browser.

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

// Normalized comparison of `expected` (an ESTree JSON value) with `actual`.
export function astDiff(expected, actual) {
  return firstDiff(normalize(expected), normalize(JSON.parse(JSON.stringify(actual, jsonReplacer))));
}
