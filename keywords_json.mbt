///|
fn[T] keyword_from_json(
  json : Json,
  path : @json.JsonPath,
  what : String,
  parse : (StringView) -> T?,
) -> T raise @json.JsonDecodeError {
  guard json is String(text) else { decode_fail(path, "expected a string") }
  match parse(text) {
    Some(value) => value
    None => decode_fail(path, "invalid \{what}: `\{text}`")
  }
}

///|
pub impl ToJson for UnaryOperator with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for UnaryOperator with fn from_json(json, path) {
  keyword_from_json(json, path, "unary operator", UnaryOperator::parse)
}

///|
pub impl ToJson for UpdateOperator with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for UpdateOperator with fn from_json(json, path) {
  keyword_from_json(json, path, "update operator", UpdateOperator::parse)
}

///|
pub impl ToJson for BinaryOperator with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for BinaryOperator with fn from_json(json, path) {
  keyword_from_json(json, path, "binary operator", BinaryOperator::parse)
}

///|
pub impl ToJson for LogicalOperator with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for LogicalOperator with fn from_json(json, path) {
  keyword_from_json(json, path, "logical operator", LogicalOperator::parse)
}

///|
pub impl ToJson for AssignmentOperator with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for AssignmentOperator with fn from_json(json, path) {
  keyword_from_json(
    json,
    path,
    "assignment operator",
    AssignmentOperator::parse,
  )
}

///|
pub impl ToJson for VariableKind with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for VariableKind with fn from_json(json, path) {
  keyword_from_json(json, path, "variable kind", VariableKind::parse)
}

///|
pub impl ToJson for PropertyKind with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for PropertyKind with fn from_json(json, path) {
  keyword_from_json(json, path, "property kind", PropertyKind::parse)
}

///|
pub impl ToJson for MethodKind with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for MethodKind with fn from_json(json, path) {
  keyword_from_json(json, path, "method kind", MethodKind::parse)
}

///|
pub impl ToJson for SourceType with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for SourceType with fn from_json(json, path) {
  keyword_from_json(json, path, "source type", SourceType::parse)
}

///|
pub impl ToJson for ImportPhase with fn to_json(self) {
  Json(self.to_string())
}

///|
pub impl FromJson for ImportPhase with fn from_json(json, path) {
  keyword_from_json(json, path, "import phase", ImportPhase::parse)
}
