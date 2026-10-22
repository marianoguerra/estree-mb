// Parses every fixtures/js/* source with acorn and writes the ESTree JSON to
// fixtures/json/<name>.json. `.cjs` files are parsed as scripts, everything
// else as modules.
import * as acorn from "acorn";
import { readdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename, extname, join } from "node:path";

const root = join(import.meta.dirname, "..", "fixtures");
const jsDir = join(root, "js");
const jsonDir = join(root, "json");

// RegExp and BigInt literal values have no JSON form; ESTree consumers rely on
// `regex` / `bigint` instead, so they serialize as `null`.
const replacer = (_key, value) =>
  typeof value === "bigint" || value instanceof RegExp ? null : value;

for (const file of readdirSync(jsDir).sort()) {
  const ext = extname(file);
  const ast = acorn.parse(readFileSync(join(jsDir, file), "utf8"), {
    ecmaVersion: "latest",
    sourceType: ext === ".cjs" ? "script" : "module",
    locations: true,
    ranges: true,
  });
  const out = join(jsonDir, `${basename(file, ext)}.json`);
  writeFileSync(out, JSON.stringify(ast, replacer, 2) + "\n");
  console.log(`wrote ${out}`);
}
