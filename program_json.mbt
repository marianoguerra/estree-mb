///|
pub impl ToJson for Program with fn to_json(self) {
  let body : Array[Json] = self.directives.map(d => Json(d))
  for item in self.body {
    body.push(Json(item))
  }
  node("Program", self.info, [
    ("body", Json::array(body)),
    ("sourceType", Json(self.source_type)),
  ])
}

///|
pub impl FromJson for Program with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("Program")
  let (directives, items, items_path, first) = decode_prologue(o, "body")
  let body : Array[ModuleItem] = []
  for i in first..<items.length() {
    body.push(FromJson::from_json(items[i], items_path.add_index(i)))
  }
  {
    info: o.info(),
    source_type: o.nullable("sourceType").unwrap_or(Script),
    directives,
    body,
  }
}

///|
pub impl ToJson for ModuleItem with fn to_json(self) {
  match self {
    Statement(x) => Json(x)
    Module(x) => Json(x)
  }
}

///|
pub impl FromJson for ModuleItem with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match ModuleDeclaration::decode(o) {
    Some(declaration) => Module(declaration)
    None => Statement(Statement::decode(o))
  }
}

///|
pub impl ToJson for Directive with fn to_json(self) {
  node("ExpressionStatement", self.info, [
    ("expression", Json(self.expression)),
    ("directive", Json(self.directive)),
  ])
}

///|
fn Directive::decode(o : Obj) -> Directive raise @json.JsonDecodeError {
  {
    info: o.info(),
    expression: o.get("expression"),
    directive: o.get("directive"),
  }
}

///|
pub impl FromJson for Directive with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("ExpressionStatement")
  Directive::decode(o)
}
