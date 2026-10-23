# estree

The [ESTree](https://github.com/estree/estree) JavaScript AST as idiomatic
MoonBit types, with a lossless JSON codec.

Coverage: ES5 through ES2026, plus the stage 3 extensions (decorators,
`accessor` fields, source-phase and deferred imports).

## Design

- **One struct per node.** ESTree's `<:` hierarchies and union-typed fields
  become enums that wrap those structs. For example, `Expression::Binary(BinaryExpression)`,
  `Statement::Declaration(Declaration::Variable(...))` and
  `Pattern::Rest(RestElement)`.
- **Invalid states are harder to express.**
  - The `computed` flag lives in `PropertyKey::Computed` and `MemberProperty::Computed`.
  - The arrow `expression` flag comes from `ArrowBody`.
  - Directive prologues are split into `directives` on `Program` and `FunctionBody`.
  - Operators and `kind`s are enums.
- **Naming.**
  - Fields use snake_case (`super_class`).
  - Booleans read as predicates (`is_async`, `is_static`, `is_optional`).
  - Keywords get a trailing underscore (`test_`, `local_`).
- **Positions.** Every node has `info : NodeInfo`. It carries the spec's `loc`
  and the common non-spec `start`/`end`/`range` offsets, so acorn/espree output
  roundtrips exactly.

All node types live in one package because they are mutually recursive. The
files follow the logical ESTree groups: `expressions.mbt`, `statements.mbt`,
`patterns.mbt`, `functions.mbt`, `classes.mbt`, `modules.mbt`, and so on. Each
group's codec is in the matching `*_json.mbt` file.

## JSON

Every node implements `ToJson` and `FromJson`. Decode errors carry the JSON path
of the offending value.

```mbt check
///|
test "parse, inspect and re-encode" {
  let program = @estree.Program::parse_json(
    (
      #|{"type":"Program","sourceType":"module","body":[
      #|  {"type":"ExpressionStatement","expression":{
      #|    "type":"BinaryExpression","operator":"+",
      #|    "left":{"type":"Identifier","name":"a"},
      #|    "right":{"type":"Literal","value":1,"raw":"1"}}}]}
    ),
  )
  guard program.body
    is [
      Statement(Expression({ expression: Binary({ operator: Add, .. }), .. })),
    ] else {
    fail("expected `a + 1`")
  }
  inspect(
    program.to_json_string(),
    content=(
      #|{"type":"Program","body":[{"type":"ExpressionStatement","expression":{"type":"BinaryExpression","left":{"type":"Identifier","name":"a"},"operator":"+","right":{"type":"Literal","value":1,"raw":"1"}}}],"sourceType":"module"}
    ),
  )
}
```

The encoder writes acorn's shape:

- Nullable spec fields are written as `null`.
- `attributes: []` and `options: null` are always present.
- Functions carry `expression`.
- Calls and member accesses carry `optional`.
- The stage-3-only keys `decorators` and `phase` are left out when they are
  empty.

The decoder is lenient. A missing key, `null`, and `[]` all decode the same
way.

## Code generation

The `codegen` package turns an AST back into JavaScript:

```mbt nocheck
let js = @codegen.program(program) // also: @codegen.statement, @codegen.expression
let tabs = @codegen.program(program, indent="\t", line_end="\r\n")
```

The output matches [astring](https://github.com/davidbonnet/astring) 1.9.0
byte for byte, except where astring's code does not reparse to the same AST:

| Input | astring | `codegen` |
| --- | --- | --- |
| `(a?.b).c`, `(a?.b)()`, `new (a?.b)()` | `a?.b.c`, `a?.b()` (continues the chain) | parenthesized |
| `export default (function () {})` / `(class {})` | bare, which reparses as a declaration | parenthesized |
| string module names, e.g. `export {a as "b"}` | `undefined` | the string literal |
| import attribute with a string key | `undefined: "v"` | `"key": "v"` |
| `import(src, options)` | drops `options` | kept |
| `import source x`, `import defer * as x`, `import.source(...)` | phase dropped | kept |
| decorators, `accessor` fields | crashes | `@dec class ...`, `accessor x = 1;` |
| statement starting with `let [` | unguarded | parenthesized |

Literals are written from their `raw` text when present. Otherwise strings are
quoted like `JSON.stringify` and numbers are written like JavaScript's
`String(number)`.

## Tests

`fixtures/js/*` holds sample sources that together cover every node type and
operator, plus `codegen_precedence.js` for tricky parenthesization.
`tools/gen_fixtures.mjs` parses them with acorn into `fixtures/json/*.json`.
`fixtures/json/stage3_*.json` is written by hand, because acorn does not
support those proposals.

`tools/gen_codegen_oracle.mjs` records astring's output for each fixture in
`fixtures/codegen/*.json`. It flags each top-level item as trusted only when
astring's code for it reparses to the same AST.

`tools/embed_fixtures.mbtx` embeds everything into two generated test files:

- `fixtures_test.mbt` checks `json → Program → json` for each fixture.
- `codegen/oracle_test.mbt` compares our output with astring's on every
  trusted item.

`tools/check_codegen.mjs` checks the generator end to end through `cmd/gen`:

- Every fixture is generated and reparsed. acorn does the reparsing, except
  for stage 3 fixtures, which use oxc. The AST must be unchanged.
- Generation is idempotent: `gen(parse(gen(ast))) == gen(ast)`.
- The real-world files listed in `tools/corpus.json` (acorn, astring, Babel's
  parser and others) must reparse to the same AST. Lines that differ from
  astring's output are reported for information.

```sh
npm --prefix tools install
node tools/gen_fixtures.mjs && node tools/gen_codegen_oracle.mjs
moon run tools/embed_fixtures.mbtx
moon test
node tools/check_codegen.mjs
```
