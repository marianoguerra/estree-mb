// End-to-end check of the MoonBit code generator (cmd/gen):
//
//   1. fixtures: every fixtures/json program is generated and reparsed (acorn,
//      or oxc for stage 3); the AST must equal the fixture, ignoring positions.
//   2. idempotency: reparsing our output and generating again yields the same
//      text, i.e. gen(parse(gen(ast))) == gen(ast).
//   3. corpus: real-world files listed in corpus.json are parsed with acorn,
//      generated, and reparsed to the same AST. Differences from astring's
//      text are counted for information only.
//
// Run from anywhere: node tools/check_codegen.mjs
import { generate } from "astring";
import { execFileSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { astDiff, jsonReplacer, parseAcorn, reparse } from "./estree_compare.mjs";

const moduleRoot = join(import.meta.dirname, "..");
const fixturesDir = join(moduleRoot, "fixtures", "json");
const work = mkdtempSync(join(tmpdir(), "estree-codegen-"));
const dirs = Object.fromEntries(
  ["input", "output", "reparsed", "regenerated"].map((d) => [d, join(work, d)]),
);
Object.values(dirs).forEach((d) => mkdirSync(d));

// Runs the MoonBit generator over every *.json in `inDir`.
function runGenerator(inDir, outDir) {
  const out = execFileSync(
    "moon",
    ["run", "--target", "native", "--release", "cmd/gen", "--", inDir, outDir],
    { cwd: moduleRoot, encoding: "utf8", maxBuffer: 1 << 26 },
  );
  for (const line of out.split("\n")) {
    if (line.startsWith("error ")) failures.push(`generator ${line}`);
  }
}

const failures = [];
const cases = []; // { name, sourceType, expected (ESTree JSON value) }

for (const file of readdirSync(fixturesDir).sort()) {
  const name = file.replace(/\.json$/, "");
  const text = readFileSync(join(fixturesDir, file), "utf8");
  writeFileSync(join(dirs.input, file), text);
  const ast = JSON.parse(text);
  cases.push({ name, sourceType: ast.sourceType ?? "script", expected: ast, corpus: false });
}

const corpus = JSON.parse(readFileSync(join(import.meta.dirname, "corpus.json"), "utf8"));
for (const { path, sourceType } of corpus) {
  const name = `corpus_${path.replace(/[^A-Za-z0-9]+/g, "_")}`;
  const ast = parseAcorn(readFileSync(join(import.meta.dirname, "node_modules", path), "utf8"), sourceType);
  const json = JSON.stringify(ast, jsonReplacer);
  writeFileSync(join(dirs.input, `${name}.json`), json);
  cases.push({ name, sourceType, expected: JSON.parse(json), corpus: true, source: ast });
}

runGenerator(dirs.input, dirs.output);

// 1 + 3: reparse our output and compare with the input AST.
for (const c of cases) {
  let code;
  try {
    code = readFileSync(join(dirs.output, `${c.name}.js`), "utf8");
  } catch {
    failures.push(`${c.name}: no output`);
    continue;
  }
  c.code = code;
  let reparsed;
  try {
    reparsed = reparse(c.name, code, c.sourceType);
  } catch (e) {
    failures.push(`${c.name}: output does not parse: ${e.message}`);
    continue;
  }
  const diff = astDiff(c.expected, reparsed);
  if (diff) {
    failures.push(`${c.name}: reparsed AST differs at ${diff}`);
    continue;
  }
  writeFileSync(join(dirs.reparsed, `${c.name}.json`), JSON.stringify(reparsed, jsonReplacer));
}

// 2: generating from the reparsed AST must reproduce the same text.
runGenerator(dirs.reparsed, dirs.regenerated);
for (const c of cases) {
  if (c.code === undefined) continue;
  let again;
  try {
    again = readFileSync(join(dirs.regenerated, `${c.name}.js`), "utf8");
  } catch {
    continue; // already reported above
  }
  if (again !== c.code) failures.push(`${c.name}: not idempotent`);
}

// Informational: corpus lines that differ from astring's output.
for (const c of cases.filter((c) => c.corpus && c.code !== undefined)) {
  const theirs = generate(c.source).split("\n");
  const ours = c.code.split("\n");
  const differing = ours.filter((line, i) => line !== theirs[i]).length;
  console.log(`${c.name}: ${ours.length} lines, ${differing} differ from astring`);
}

rmSync(work, { recursive: true, force: true });
console.log(`${cases.length} programs checked (${corpus.length} corpus files)`);
if (failures.length > 0) {
  console.log(`FAILED (${failures.length}):\n  ${failures.join("\n  ")}`);
  process.exit(1);
}
console.log("all reparse and idempotency checks passed");
