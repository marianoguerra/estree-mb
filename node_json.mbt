///|
fn[T] decode_fail(
  path : @json.JsonPath,
  message : String,
) -> T raise @json.JsonDecodeError {
  raise @json.JsonDecodeError((path, message))
}

///|
/// A JSON object being decoded as an ESTree node, together with its path for
/// error reporting.
priv struct Obj {
  fields : Map[String, Json]
  path : @json.JsonPath
}

///|
fn Obj::new(
  json : Json,
  path : @json.JsonPath,
) -> Obj raise @json.JsonDecodeError {
  guard json is Object(fields) else { decode_fail(path, "expected an object") }
  { fields, path, }
}

///|
/// The node's `type` discriminant.
fn Obj::type_(self : Obj) -> String raise @json.JsonDecodeError {
  self.get("type")
}

///|
fn Obj::expect_type(
  self : Obj,
  expected : String,
) -> Unit raise @json.JsonDecodeError {
  let actual = self.type_()
  if actual != expected {
    decode_fail(
      self.path.add_key("type"),
      "expected node type `\{expected}`, got `\{actual}`",
    )
  }
}

///|
fn[T] Obj::unexpected_type(
  self : Obj,
  what : String,
  actual : String,
) -> T raise @json.JsonDecodeError {
  decode_fail(self.path.add_key("type"), "unexpected \{what} type `\{actual}`")
}

///|
/// Whether `key` is present with a non-null value.
fn Obj::has(self : Obj, key : String) -> Bool {
  self.fields.get(key) is Some(value) && !(value is Null)
}

///|
fn Obj::child(self : Obj, key : String) -> Obj raise @json.JsonDecodeError {
  match self.fields.get(key) {
    Some(json) => Obj::new(json, self.path.add_key(key))
    None => decode_fail(self.path, "missing field `\{key}`")
  }
}

///|
/// A required field.
fn[T : FromJson] Obj::get(
  self : Obj,
  key : String,
) -> T raise @json.JsonDecodeError {
  match self.fields.get(key) {
    Some(json) => FromJson::from_json(json, self.path.add_key(key))
    None => decode_fail(self.path, "missing field `\{key}`")
  }
}

///|
/// A nullable field; a missing key also decodes as `None`.
fn[T : FromJson] Obj::nullable(
  self : Obj,
  key : String,
) -> T? raise @json.JsonDecodeError {
  match self.fields.get(key) {
    None | Some(Null) => None
    Some(json) => Some(FromJson::from_json(json, self.path.add_key(key)))
  }
}

///|
/// A boolean flag; a missing key or `null` decodes as `false`.
fn Obj::flag(self : Obj, key : String) -> Bool raise @json.JsonDecodeError {
  self.nullable(key).unwrap_or(false)
}

///|
/// A list field; a missing key or `null` decodes as an empty array.
fn[T : FromJson] Obj::list(
  self : Obj,
  key : String,
) -> Array[T] raise @json.JsonDecodeError {
  self.nullable(key).unwrap_or([])
}

///|
/// A list whose elements may be `null` (array holes).
fn[T : FromJson] Obj::sparse_list(
  self : Obj,
  key : String,
) -> Array[T?] raise @json.JsonDecodeError {
  let path = self.path.add_key(key)
  match self.fields.get(key) {
    Some(Array(items)) =>
      items.mapi((i, item) => {
        match item {
          Null => None
          json => Some(FromJson::from_json(json, path.add_index(i)))
        }
      })
    Some(_) => decode_fail(path, "expected an array")
    None => decode_fail(self.path, "missing field `\{key}`")
  }
}

///|
fn Obj::info(self : Obj) -> NodeInfo raise @json.JsonDecodeError {
  {
    loc: self.nullable("loc"),
    start: self.nullable("start"),
    end: self.nullable("end"),
    range: match self.fields.get("range") {
      None | Some(Null) => None
      Some(Array([Number(start, ..), Number(end, ..)])) =>
        Some((start.to_int(), end.to_int()))
      Some(_) =>
        decode_fail(self.path.add_key("range"), "expected `[start, end]`")
    },
  }
}

///|
/// Encodes a node as `{ type, start, end, loc, range, ...fields }`.
fn node(
  type_ : String,
  info : NodeInfo,
  fields : Array[(String, Json)],
) -> Json {
  let map : Map[String, Json] = Map([])
  map["type"] = Json(type_)
  if info.start is Some(start) {
    map["start"] = Json(start)
  }
  if info.end is Some(end) {
    map["end"] = Json(end)
  }
  if info.loc is Some(loc) {
    map["loc"] = Json(loc)
  }
  if info.range is Some((start, end)) {
    map["range"] = Json::array([Json(start), Json(end)])
  }
  for field in fields {
    map[field.0] = field.1
  }
  Json::object(map)
}

///|
/// Encodes an optional value as the value itself or `null`.
fn[T : ToJson] nullable(value : T?) -> Json {
  match value {
    Some(value) => Json(value)
    None => Json::null()
  }
}

///|
/// Encodes an array whose `None` elements become `null` holes.
fn[T : ToJson] sparse(items : Array[T?]) -> Json {
  Json::array(items.map(nullable))
}

///|
pub impl ToJson for Position with fn to_json(self) {
  { "line": Json(self.line), "column": Json(self.column) }
}

///|
pub impl FromJson for Position with fn from_json(json, path) {
  let o = Obj::new(json, path)
  { line: o.get("line"), column: o.get("column"), }
}

///|
pub impl ToJson for SourceLocation with fn to_json(self) {
  let map : Map[String, Json] = Map([])
  if self.source is Some(source) {
    map["source"] = Json(source)
  }
  map["start"] = Json(self.start)
  map["end"] = Json(self.end)
  Json::object(map)
}

///|
pub impl FromJson for SourceLocation with fn from_json(json, path) {
  let o = Obj::new(json, path)
  { source: o.nullable("source"), start: o.get("start"), end: o.get("end"), }
}
