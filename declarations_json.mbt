///|
pub impl ToJson for Declaration with fn to_json(self) {
  match self {
    Function(x) => x.encode("FunctionDeclaration")
    Variable(x) => Json(x)
    Class(x) => x.encode("ClassDeclaration")
  }
}

///|
fn Declaration::decode(o : Obj) -> Declaration raise @json.JsonDecodeError {
  match o.type_() {
    "FunctionDeclaration" => Function(Function::decode(o))
    "VariableDeclaration" => Variable(VariableDeclaration::decode(o))
    "ClassDeclaration" => Class(Class::decode(o))
    other => o.unexpected_type("declaration", other)
  }
}

///|
pub impl FromJson for Declaration with fn from_json(json, path) {
  Declaration::decode(Obj::new(json, path))
}

///|
pub impl ToJson for VariableDeclaration with fn to_json(self) {
  node("VariableDeclaration", self.info, [
    ("declarations", Json(self.declarations)),
    ("kind", Json(self.kind)),
  ])
}

///|
fn VariableDeclaration::decode(
  o : Obj,
) -> VariableDeclaration raise @json.JsonDecodeError {
  { info: o.info(), declarations: o.get("declarations"), kind: o.get("kind"), }
}

///|
pub impl FromJson for VariableDeclaration with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("VariableDeclaration")
  VariableDeclaration::decode(o)
}

///|
pub impl ToJson for VariableDeclarator with fn to_json(self) {
  node("VariableDeclarator", self.info, [
    ("id", Json(self.id)),
    ("init", nullable(self.init)),
  ])
}

///|
pub impl FromJson for VariableDeclarator with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("VariableDeclarator")
  { info: o.info(), id: o.get("id"), init: o.nullable("init"), }
}
