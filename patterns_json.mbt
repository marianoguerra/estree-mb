///|
pub impl ToJson for Pattern with fn to_json(self) {
  match self {
    Identifier(x) => Json(x)
    Member(x) => Json(x)
    Object(x) => Json(x)
    Array(x) => Json(x)
    Rest(x) => Json(x)
    Assignment(x) => Json(x)
  }
}

///|
fn Pattern::decode(o : Obj) -> Pattern raise @json.JsonDecodeError {
  match o.type_() {
    "Identifier" => Identifier(Identifier::decode(o))
    "MemberExpression" => Member(MemberExpression::decode(o))
    "ObjectPattern" => Object(ObjectPattern::decode(o))
    "ArrayPattern" => Array(ArrayPattern::decode(o))
    "RestElement" => Rest(RestElement::decode(o))
    "AssignmentPattern" => Assignment(AssignmentPattern::decode(o))
    other => o.unexpected_type("pattern", other)
  }
}

///|
pub impl FromJson for Pattern with fn from_json(json, path) {
  Pattern::decode(Obj::new(json, path))
}

///|
pub impl ToJson for ObjectPattern with fn to_json(self) {
  node("ObjectPattern", self.info, [("properties", Json(self.properties))])
}

///|
fn ObjectPattern::decode(o : Obj) -> ObjectPattern raise @json.JsonDecodeError {
  { info: o.info(), properties: o.get("properties"), }
}

///|
pub impl ToJson for ObjectPatternMember with fn to_json(self) {
  match self {
    Property(x) => Json(x)
    Rest(x) => Json(x)
  }
}

///|
pub impl FromJson for ObjectPatternMember with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "Property" => Property(AssignmentProperty::decode(o))
    "RestElement" => Rest(RestElement::decode(o))
    other => o.unexpected_type("object pattern member", other)
  }
}

///|
pub impl ToJson for AssignmentProperty with fn to_json(self) {
  node(
    "Property",
    self.info,
    [
      ("method", Json(false)),
      ("shorthand", Json(self.is_shorthand)),
      ..self.key.fields(),
      ("value", Json(self.value)),
      ("kind", Json("init")),
    ],
  )
}

///|
fn AssignmentProperty::decode(
  o : Obj,
) -> AssignmentProperty raise @json.JsonDecodeError {
  {
    info: o.info(),
    key: PropertyKey::decode(o),
    value: o.get("value"),
    is_shorthand: o.flag("shorthand"),
  }
}

///|
pub impl ToJson for ArrayPattern with fn to_json(self) {
  node("ArrayPattern", self.info, [("elements", sparse(self.elements))])
}

///|
fn ArrayPattern::decode(o : Obj) -> ArrayPattern raise @json.JsonDecodeError {
  { info: o.info(), elements: o.sparse_list("elements"), }
}

///|
pub impl ToJson for RestElement with fn to_json(self) {
  node("RestElement", self.info, [("argument", Json(self.argument))])
}

///|
fn RestElement::decode(o : Obj) -> RestElement raise @json.JsonDecodeError {
  { info: o.info(), argument: o.get("argument"), }
}

///|
pub impl ToJson for AssignmentPattern with fn to_json(self) {
  node("AssignmentPattern", self.info, [
    ("left", Json(self.left)),
    ("right", Json(self.right)),
  ])
}

///|
fn AssignmentPattern::decode(
  o : Obj,
) -> AssignmentPattern raise @json.JsonDecodeError {
  { info: o.info(), left: o.get("left"), right: o.get("right"), }
}
