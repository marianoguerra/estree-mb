// Playground: acorn parses the editor contents, the MoonBit library (wasm-gc or
// js build) decodes the ESTree JSON, re-encodes it and generates code, and the
// result is checked against acorn (reparse) and astring (text).
import { EditorState, Compartment } from "@codemirror/state";
import { EditorView } from "@codemirror/view";
import { basicSetup } from "codemirror";
import { javascript } from "@codemirror/lang-javascript";
import { json } from "@codemirror/lang-json";
import { oneDark } from "@codemirror/theme-one-dark";
import * as acorn from "acorn";
import { generate } from "astring";
import { astDiff, firstDiff, jsonReplacer } from "./ast_diff.mjs";

const $ = (id) => document.getElementById(id);
const darkQuery = matchMedia("(prefers-color-scheme: dark)");
const theme = () => (darkQuery.matches ? oneDark : []);

// --- library targets --------------------------------------------------------

const loaders = {
  js: async () => (await import("./playground.js")).process,
  "wasm-gc": async () => {
    const { instance } = await WebAssembly.instantiateStreaming(
      fetch("./playground.wasm"),
      {},
      { builtins: ["js-string"], importedStringConstants: "_" },
    );
    return instance.exports.process;
  },
};
const loaded = new Map(); // target -> Promise<process>

function loadTarget(target) {
  if (!loaded.has(target)) loaded.set(target, loaders[target]());
  return loaded.get(target);
}

// --- editors ----------------------------------------------------------------

const themes = [new Compartment(), new Compartment()];
const outputLanguage = new Compartment();

const input = new EditorView({
  parent: $("editor"),
  state: EditorState.create({
    extensions: [
      basicSetup,
      javascript(),
      themes[0].of(theme()),
      EditorView.updateListener.of((u) => u.docChanged && schedule()),
    ],
  }),
});

const output = new EditorView({
  parent: $("output"),
  state: EditorState.create({
    extensions: [
      basicSetup,
      outputLanguage.of(json()),
      themes[1].of(theme()),
      EditorState.readOnly.of(true),
      EditorView.editable.of(false),
    ],
  }),
});

darkQuery.addEventListener("change", () => {
  input.dispatch({ effects: themes[0].reconfigure(theme()) });
  output.dispatch({ effects: themes[1].reconfigure(theme()) });
});

// --- state ------------------------------------------------------------------

let tab = "json";
let last = null; // { ast, astJson, ours, theirs }
let timer = 0;
let run = 0;

function schedule() {
  clearTimeout(timer);
  timer = setTimeout(update, 250);
}

const withoutPositions = (key, value) =>
  key === "start" || key === "end" || key === "loc" || key === "range"
    ? undefined
    : jsonReplacer(key, value);

function showTab() {
  for (const b of document.querySelectorAll("[role=tab]")) {
    b.setAttribute("aria-selected", String(b.dataset.tab === tab));
  }
  $("positions-field").hidden = tab !== "json";
  let text = "";
  if (last) {
    if (tab === "json") {
      text = JSON.stringify(last.ast, $("positions").checked ? jsonReplacer : withoutPositions, 2);
    } else if (tab === "ours") {
      text = last.ours ?? `// MoonBit error:\n// ${last.oursError}`;
    } else {
      text = last.theirs ?? `// astring crashed:\n// ${last.theirsError}`;
    }
  }
  output.dispatch({
    changes: { from: 0, to: output.state.doc.length, insert: text },
    effects: outputLanguage.reconfigure(tab === "json" ? json() : javascript()),
  });
}

// --- checks -----------------------------------------------------------------

function reparseDiff(original, code, sourceType) {
  try {
    return astDiff(original, acorn.parse(code, { ecmaVersion: "latest", sourceType }));
  } catch (e) {
    return `does not parse: ${e.message}`;
  }
}

function firstLineDiff(a, b) {
  const as = a.split("\n");
  const bs = b.split("\n");
  for (let i = 0; i < Math.max(as.length, bs.length); i++) {
    if (as[i] !== bs[i]) {
      return `line ${i + 1}\n  moonbit: ${as[i] ?? "<end>"}\n  astring: ${bs[i] ?? "<end>"}`;
    }
  }
  return null;
}

function renderReport(rows) {
  $("report").replaceChildren(
    ...rows.map(({ status, label, detail }) => {
      const li = document.createElement("li");
      const mark = document.createElement("span");
      mark.className = status;
      mark.textContent = { ok: "✓", bad: "✗", warn: "!" }[status];
      const name = document.createElement("span");
      name.textContent = label;
      const info = document.createElement("span");
      info.className = "detail";
      info.textContent = detail;
      li.append(mark, name, info);
      return li;
    }),
  );
}

function setVerdict(status, text) {
  const v = $("verdict");
  v.className = `verdict ${status}`;
  v.textContent = text;
}

function setMark(name, status) {
  const el = document.querySelector(`[data-mark=${name}]`);
  el.className = `mark ${status}`;
  el.textContent = { ok: "✓", bad: "✗", warn: "!" }[status] ?? "";
}

// --- pipeline ---------------------------------------------------------------

async function update() {
  const id = ++run;
  const target = $("target").value;
  const sourceType = $("source-type").value;
  const source = input.state.doc.toString();

  let ast;
  try {
    ast = acorn.parse(source, { ecmaVersion: "latest", sourceType, locations: true, ranges: true });
    $("parse-error").hidden = true;
    document.body.classList.remove("stale");
  } catch (e) {
    $("parse-error").textContent = `acorn: ${e.message}`;
    $("parse-error").hidden = false;
    document.body.classList.add("stale");
    return;
  }

  let process;
  try {
    process = await loadTarget(target);
  } catch (e) {
    setVerdict("bad", `${target} unavailable`);
    renderReport([{ status: "bad", label: `load ${target}`, detail: e.message }]);
    return;
  }
  if (id !== run) return;

  const astJson = JSON.stringify(ast, jsonReplacer);
  const t0 = performance.now();
  let result;
  try {
    result = JSON.parse(process(astJson));
  } catch (e) {
    result = { ok: false, error: `trap: ${e.message}` };
  }
  const elapsed = performance.now() - t0;
  $("timing").textContent = `${target}: ${elapsed.toFixed(1)} ms (decode + encode + codegen)`;

  let theirs = null;
  let theirsError = null;
  try {
    theirs = generate(ast);
  } catch (e) {
    theirsError = e.message;
  }

  const expected = JSON.parse(astJson);
  const rows = [];
  const ours = result.ok ? result.code : null;

  if (!result.ok) {
    rows.push({ status: "bad", label: "MoonBit decode", detail: result.error });
  } else {
    const diff = firstDiff(expected, JSON.parse(result.json));
    rows.push(
      diff
        ? { status: "bad", label: "JSON roundtrip", detail: diff }
        : { status: "ok", label: "JSON roundtrip", detail: "decode → encode equals acorn's JSON" },
    );
  }

  const oursDiff = ours === null ? "no output" : reparseDiff(expected, ours, sourceType);
  rows.push(
    oursDiff
      ? { status: "bad", label: "reparse MoonBit", detail: oursDiff }
      : { status: "ok", label: "reparse MoonBit", detail: "acorn parses the output to the same AST" },
  );

  const theirsDiff = theirs === null ? `astring crashed: ${theirsError}` : reparseDiff(expected, theirs, sourceType);
  rows.push(
    theirsDiff
      ? { status: "warn", label: "reparse astring", detail: theirsDiff }
      : { status: "ok", label: "reparse astring", detail: "acorn parses astring's output to the same AST" },
  );

  const textDiff = ours !== null && theirs !== null ? firstLineDiff(ours, theirs) : "missing output";
  let verdict;
  if (!result.ok || oursDiff || rows[0].status === "bad") {
    verdict = ["bad", "MoonBit output is wrong"];
    rows.push({ status: textDiff ? "bad" : "ok", label: "MoonBit = astring", detail: textDiff ?? "identical" });
  } else if (!textDiff) {
    verdict = ["ok", "outputs match"];
    rows.push({ status: "ok", label: "MoonBit = astring", detail: "byte-identical" });
  } else if (theirsDiff) {
    verdict = ["warn", "outputs differ: astring is wrong"];
    rows.push({ status: "warn", label: "MoonBit ≠ astring", detail: `${textDiff}\n(expected: astring's output does not reparse)` });
  } else {
    verdict = ["bad", "outputs differ"];
    rows.push({ status: "bad", label: "MoonBit ≠ astring", detail: textDiff });
  }

  setVerdict(...verdict);
  setMark("ours", oursDiff ? "bad" : "ok");
  setMark("astring", theirsDiff ? "warn" : "ok");
  renderReport(rows);
  last = { ast, ours, oursError: result.error, theirs, theirsError };
  showTab();
}

// --- wiring -----------------------------------------------------------------

for (const b of document.querySelectorAll("[role=tab]")) {
  b.addEventListener("click", () => {
    tab = b.dataset.tab;
    showTab();
  });
}
$("positions").addEventListener("change", showTab);
$("target").addEventListener("change", update);
$("source-type").addEventListener("change", update);

const examples = await (await fetch("./examples.json")).json();
for (const [i, ex] of examples.entries()) {
  const option = new Option(ex.name, String(i));
  $("example").append(option);
}

function loadExample(i) {
  const ex = examples[i];
  $("source-type").value = ex.sourceType;
  input.dispatch({ changes: { from: 0, to: input.state.doc.length, insert: ex.code } });
}

$("example").addEventListener("change", (e) => loadExample(Number(e.target.value)));

// wasm-gc needs the JS string builtins; fall back to js when they're missing.
try {
  await loadTarget("wasm-gc");
} catch (e) {
  loaded.delete("wasm-gc");
  const option = $("target").querySelector("[value=wasm-gc]");
  option.disabled = true;
  option.textContent = "wasm-gc (needs JS string builtins)";
  $("target").value = "js";
}

loadExample(0);
