///|
/// Checks our output against astring's recorded output for a fixture: the
/// whole program when astring got all of it right, otherwise each top-level
/// item astring got right. Items astring gets wrong are covered by the acorn
/// reparse in tools/check_codegen.mjs.
fn check_oracle(source : String, oracle : String) -> Unit raise {
  let program = @estree.Program::parse_json(source)
  guard @json.parse(oracle)
    is { "program": expected_program, "items": Array(items), .. } else {
    fail("malformed oracle record")
  }
  if expected_program is String(expected) {
    assert_same_code("program", @codegen.program(program), expected)
  }
  let directives = program.directives.length()
  for i, item in items {
    guard item is { "code": String(expected), "trusted": True, .. } else {
      continue
    }
    let single : @estree.Program = if i < directives {
      { ..program, directives: [program.directives[i]], body: [], }
    } else {
      { ..program, directives: [], body: [program.body[i - directives]], }
    }
    assert_same_code("item \{i}", @codegen.program(single), expected)
  }
}

///|
fn assert_same_code(
  what : String,
  actual : String,
  expected : String,
) -> Unit raise {
  if actual == expected {
    return
  }
  let actual_lines = actual.split("\n").collect()
  let expected_lines = expected.split("\n").collect()
  for i, line in expected_lines {
    let got = actual_lines.get(i).map(v => v.to_owned()).unwrap_or("<missing>")
    if got != line.to_owned() {
      fail("\{what}, line \{i + 1}:\n  astring: \{line}\n  ours:    \{got}")
    }
  }
  fail("\{what}: extra output after line \{expected_lines.length()}")
}
