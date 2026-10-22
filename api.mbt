///|
/// Decodes an ESTree `Program` from a JSON string.
///
/// Raises `@json.ParseError` for malformed JSON and `@json.JsonDecodeError`
/// (with the JSON path of the offending value) for JSON that is not a valid
/// ESTree program.
pub fn Program::parse_json(source : StringView) -> Program raise {
  @json.from_json(@json.parse(source))
}

///|
/// Encodes the program as an ESTree JSON string.
pub fn Program::to_json_string(self : Program, indent~ : Int32 = 0) -> String {
  Json(self).stringify(indent~)
}
