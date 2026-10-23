// Records astring's output for every fixture in fixtures/codegen/<name>.json,
// flagging each top-level item as trusted only when astring's code for it
// reparses to the same AST. Untrusted items are where astring is wrong (or
// crashes) and our generator intentionally diverges.
//
//   { "program": <astring text, or null unless every item is trusted>,
//     "items": [{ "code": <astring text for the item alone>, "trusted": bool }] }
import { generate } from "astring";
import { mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { astDiff, parseOxc, reparse } from "./estree_compare.mjs";

const root = join(import.meta.dirname, "..", "fixtures");
const outDir = join(root, "codegen");
mkdirSync(outDir, { recursive: true });

const tryGenerate = (ast) => {
  try {
    return generate(ast);
  } catch {
    return null;
  }
};

let untrustedTotal = 0;
for (const file of readdirSync(join(root, "json")).sort()) {
  const name = file.replace(/\.json$/, "");
  const ast = JSON.parse(readFileSync(join(root, "json", file), "utf8"));
  const sourceType = ast.sourceType ?? "script";

  // Whole program first: the strict oracle sees full module context.
  const whole = tryGenerate(ast);
  let wholeTrusted = false;
  if (whole !== null) {
    try {
      wholeTrusted = astDiff(ast, reparse(name, whole, sourceType)) === null;
    } catch {}
  }

  const items = ast.body.map((item) => {
    const code = tryGenerate({ ...ast, body: [item] });
    if (code === null) return { code: null, trusted: false };
    if (wholeTrusted) return { code, trusted: true };
    // Per item, oxc is used: acorn rejects e.g. `export {a}` without `a`.
    let trusted = false;
    try {
      const reparsed = parseOxc(code, sourceType);
      trusted = astDiff({ ...ast, body: [item] }, reparsed) === null;
    } catch {}
    return { code, trusted };
  });

  const untrusted = items.filter((i) => !i.trusted).length;
  untrustedTotal += untrusted;
  const record = { program: wholeTrusted ? whole : null, items };
  writeFileSync(join(outDir, `${name}.json`), JSON.stringify(record, null, 2) + "\n");
  console.log(`${name}: ${items.length} items, ${untrusted} untrusted`);
}
console.log(`total untrusted items: ${untrustedTotal}`);
