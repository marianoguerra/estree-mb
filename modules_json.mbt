///|
pub impl ToJson for ModuleDeclaration with fn to_json(self) {
  match self {
    Import(x) => Json(x)
    ExportNamed(x) => Json(x)
    ExportDefault(x) => Json(x)
    ExportAll(x) => Json(x)
  }
}

///|
/// Decodes a module declaration, or returns `None` for any other node type.
fn ModuleDeclaration::decode(
  o : Obj,
) -> ModuleDeclaration? raise @json.JsonDecodeError {
  match o.type_() {
    "ImportDeclaration" => Some(Import(ImportDeclaration::decode(o)))
    "ExportNamedDeclaration" =>
      Some(ExportNamed(ExportNamedDeclaration::decode(o)))
    "ExportDefaultDeclaration" =>
      Some(ExportDefault(ExportDefaultDeclaration::decode(o)))
    "ExportAllDeclaration" => Some(ExportAll(ExportAllDeclaration::decode(o)))
    _ => None
  }
}

///|
pub impl FromJson for ModuleDeclaration with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match ModuleDeclaration::decode(o) {
    Some(declaration) => declaration
    None => o.unexpected_type("module declaration", o.type_())
  }
}

///|
pub impl ToJson for ModuleExportName with fn to_json(self) {
  match self {
    Identifier(x) => Json(x)
    Literal(x) => Json(x)
  }
}

///|
pub impl FromJson for ModuleExportName with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "Identifier" => Identifier(Identifier::decode(o))
    "Literal" => Literal(Literal::decode(o))
    other => o.unexpected_type("module export name", other)
  }
}

///|
pub impl ToJson for ImportDeclaration with fn to_json(self) {
  let fields = [
    ("specifiers", Json(self.specifiers)),
    ("source", Json(self.source)),
    ("attributes", Json(self.attributes)),
  ]
  if self.phase is Some(phase) {
    fields.push(("phase", Json(phase)))
  }
  node("ImportDeclaration", self.info, fields)
}

///|
fn ImportDeclaration::decode(
  o : Obj,
) -> ImportDeclaration raise @json.JsonDecodeError {
  {
    info: o.info(),
    specifiers: o.get("specifiers"),
    source: o.get("source"),
    attributes: o.list("attributes"),
    phase: o.nullable("phase"),
  }
}

///|
pub impl ToJson for ImportClause with fn to_json(self) {
  match self {
    Named(x) =>
      node("ImportSpecifier", x.info, [
        ("imported", Json(x.imported)),
        ("local", Json(x.local_)),
      ])
    Default(x) =>
      node("ImportDefaultSpecifier", x.info, [("local", Json(x.local_))])
    Namespace(x) =>
      node("ImportNamespaceSpecifier", x.info, [("local", Json(x.local_))])
  }
}

///|
pub impl FromJson for ImportClause with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "ImportSpecifier" =>
      Named({
        info: o.info(),
        imported: o.get("imported"),
        local_: o.get("local"),
      })
    "ImportDefaultSpecifier" =>
      Default({ info: o.info(), local_: o.get("local"), })
    "ImportNamespaceSpecifier" =>
      Namespace({ info: o.info(), local_: o.get("local"), })
    other => o.unexpected_type("import specifier", other)
  }
}

///|
pub impl ToJson for ImportAttribute with fn to_json(self) {
  node("ImportAttribute", self.info, [
    ("key", Json(self.key)),
    ("value", Json(self.value)),
  ])
}

///|
pub impl FromJson for ImportAttribute with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("ImportAttribute")
  { info: o.info(), key: o.get("key"), value: o.get("value"), }
}

///|
pub impl ToJson for ExportNamedDeclaration with fn to_json(self) {
  node("ExportNamedDeclaration", self.info, [
    ("declaration", nullable(self.declaration)),
    ("specifiers", Json(self.specifiers)),
    ("source", nullable(self.source)),
    ("attributes", Json(self.attributes)),
  ])
}

///|
fn ExportNamedDeclaration::decode(
  o : Obj,
) -> ExportNamedDeclaration raise @json.JsonDecodeError {
  {
    info: o.info(),
    declaration: o.nullable("declaration"),
    specifiers: o.list("specifiers"),
    source: o.nullable("source"),
    attributes: o.list("attributes"),
  }
}

///|
pub impl ToJson for ExportSpecifier with fn to_json(self) {
  node("ExportSpecifier", self.info, [
    ("local", Json(self.local_)),
    ("exported", Json(self.exported)),
  ])
}

///|
pub impl FromJson for ExportSpecifier with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("ExportSpecifier")
  { info: o.info(), local_: o.get("local"), exported: o.get("exported"), }
}

///|
pub impl ToJson for ExportDefaultDeclaration with fn to_json(self) {
  let declaration = match self.declaration {
    Function(x) => x.encode("FunctionDeclaration")
    Class(x) => x.encode("ClassDeclaration")
    Expression(x) => Json(x)
  }
  node("ExportDefaultDeclaration", self.info, [("declaration", declaration)])
}

///|
fn ExportDefaultDeclaration::decode(
  o : Obj,
) -> ExportDefaultDeclaration raise @json.JsonDecodeError {
  let d = o.child("declaration")
  let declaration : ExportDefaultKind = match d.type_() {
    "FunctionDeclaration" => Function(Function::decode(d))
    "ClassDeclaration" => Class(Class::decode(d))
    _ => Expression(Expression::decode(d))
  }
  { info: o.info(), declaration, }
}

///|
pub impl ToJson for ExportAllDeclaration with fn to_json(self) {
  node("ExportAllDeclaration", self.info, [
    ("exported", nullable(self.exported)),
    ("source", Json(self.source)),
    ("attributes", Json(self.attributes)),
  ])
}

///|
fn ExportAllDeclaration::decode(
  o : Obj,
) -> ExportAllDeclaration raise @json.JsonDecodeError {
  {
    info: o.info(),
    exported: o.nullable("exported"),
    source: o.get("source"),
    attributes: o.list("attributes"),
  }
}
