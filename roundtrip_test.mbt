///|
/// Returns the path and a description of the first difference between two
/// JSON values, or `None` when they are equal.
fn json_diff(expected : Json, actual : Json, path : String) -> String? {
  match (expected, actual) {
    (Object(e), Object(a)) => {
      for key, value in e {
        match a.get(key) {
          None => return Some("\{path}.\{key}: missing in output")
          Some(other) =>
            if json_diff(value, other, "\{path}.\{key}") is Some(diff) {
              return Some(diff)
            }
        }
      }
      for key, _ in a {
        if !e.contains(key) {
          return Some("\{path}.\{key}: unexpected in output")
        }
      }
      None
    }
    (Array(e), Array(a)) => {
      if e.length() != a.length() {
        return Some("\{path}: length \{e.length()} != \{a.length()}")
      }
      for i, value in e {
        if json_diff(value, a[i], "\{path}[\{i}]") is Some(diff) {
          return Some(diff)
        }
      }
      None
    }
    _ =>
      if expected == actual {
        None
      } else {
        Some("\{path}: \{expected.stringify()} != \{actual.stringify()}")
      }
  }
}

///|
/// Checks `json → Program → json` is lossless, and that the encoded string
/// decodes back to the same `Program`.
fn assert_roundtrip(source : String) -> Unit raise {
  let expected = @json.parse(source)
  let program : @estree.Program = @json.from_json(expected)
  if json_diff(expected, Json(program), "$") is Some(diff) {
    fail("roundtrip mismatch at \{diff}")
  }
  let reparsed = @estree.Program::parse_json(program.to_json_string())
  assert_true(reparsed == program)
}
