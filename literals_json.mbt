///|
pub impl ToJson for Identifier with fn to_json(self) {
  node("Identifier", self.info, [("name", Json(self.name))])
}

///|
fn Identifier::decode(o : Obj) -> Identifier raise @json.JsonDecodeError {
  { info: o.info(), name: o.get("name"), }
}

///|
pub impl FromJson for Identifier with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("Identifier")
  Identifier::decode(o)
}

///|
pub impl ToJson for PrivateIdentifier with fn to_json(self) {
  node("PrivateIdentifier", self.info, [("name", Json(self.name))])
}

///|
fn PrivateIdentifier::decode(
  o : Obj,
) -> PrivateIdentifier raise @json.JsonDecodeError {
  { info: o.info(), name: o.get("name"), }
}

///|
pub impl FromJson for PrivateIdentifier with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("PrivateIdentifier")
  PrivateIdentifier::decode(o)
}

///|
pub impl ToJson for Literal with fn to_json(self) {
  let fields : Array[(String, Json)] = []
  let value = match self.value {
    String(s) => Json(s)
    Boolean(b) => Json(b)
    Number(n) => Json(n)
    Null | RegExp(..) | BigInt(_) => Json::null()
  }
  fields.push(("value", value))
  if self.raw is Some(raw) {
    fields.push(("raw", Json(raw)))
  }
  match self.value {
    RegExp(pattern~, flags~) =>
      fields.push(("regex", { "pattern": Json(pattern), "flags": Json(flags) }))
    BigInt(digits) => fields.push(("bigint", Json(digits)))
    _ => ()
  }
  node("Literal", self.info, fields)
}

///|
fn Literal::decode(o : Obj) -> Literal raise @json.JsonDecodeError {
  let value : LiteralValue = if o.has("regex") {
    let regex = o.child("regex")
    RegExp(pattern=regex.get("pattern"), flags=regex.get("flags"))
  } else if o.has("bigint") {
    BigInt(o.get("bigint"))
  } else {
    match o.fields.get("value") {
      None | Some(Null) => Null
      Some(String(s)) => String(s)
      Some(True) => Boolean(true)
      Some(False) => Boolean(false)
      Some(Number(n, ..)) => Number(n)
      Some(_) => decode_fail(o.path.add_key("value"), "invalid literal value")
    }
  }
  { info: o.info(), value, raw: o.nullable("raw"), }
}

///|
pub impl FromJson for Literal with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("Literal")
  Literal::decode(o)
}
