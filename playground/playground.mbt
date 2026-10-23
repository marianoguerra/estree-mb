///|
/// Decodes an ESTree program from `estree_json`, then re-encodes it and
/// generates JavaScript from it. Returns a JSON envelope so that callers
/// across the JS / wasm-gc boundary only deal with strings:
///
/// - `{"ok":true,"json":"<re-encoded ESTree JSON>","code":"<JavaScript>"}`
/// - `{"ok":false,"error":"<message>"}`
pub fn process(estree_json : String) -> String {
  let result : Json = try @estree.Program::parse_json(estree_json) catch {
    err => { "ok": false, "error": err.to_string() }
  } noraise {
    program =>
      {
        "ok": true,
        "json": program.to_json_string(),
        "code": @codegen.program(program),
      }
  }
  result.stringify()
}
