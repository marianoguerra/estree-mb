///|
/// Appends `decorators` unless empty: the key is stage 3 only and most
/// parsers omit it.
fn push_decorators(
  fields : Array[(String, Json)],
  decorators : Array[Decorator],
) -> Array[(String, Json)] {
  if !decorators.is_empty() {
    fields.push(("decorators", Json(decorators)))
  }
  fields
}

///|
/// Encodes a class as `ClassDeclaration` or `ClassExpression`.
fn Class::encode(self : Class, type_ : String) -> Json {
  node(
    type_,
    self.info,
    push_decorators(
      [
        ("id", nullable(self.id)),
        ("superClass", nullable(self.super_class)),
        ("body", Json(self.body)),
      ],
      self.decorators,
    ),
  )
}

///|
fn Class::decode(o : Obj) -> Class raise @json.JsonDecodeError {
  {
    info: o.info(),
    id: o.nullable("id"),
    super_class: o.nullable("superClass"),
    body: o.get("body"),
    decorators: o.list("decorators"),
  }
}

///|
pub impl ToJson for ClassBody with fn to_json(self) {
  node("ClassBody", self.info, [("body", Json(self.body))])
}

///|
pub impl FromJson for ClassBody with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("ClassBody")
  { info: o.info(), body: o.get("body"), }
}

///|
pub impl ToJson for ClassElement with fn to_json(self) {
  match self {
    Method(x) => Json(x)
    Property(x) => Json(x)
    Accessor(x) => Json(x)
    StaticBlock(x) => Json(x)
  }
}

///|
pub impl FromJson for ClassElement with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "MethodDefinition" => Method(MethodDefinition::decode(o))
    "PropertyDefinition" => Property(PropertyDefinition::decode(o))
    "AccessorProperty" => Accessor(AccessorProperty::decode(o))
    "StaticBlock" => StaticBlock(StaticBlock::decode(o))
    other => o.unexpected_type("class element", other)
  }
}

///|
pub impl ToJson for MethodDefinition with fn to_json(self) {
  node(
    "MethodDefinition",
    self.info,
    push_decorators(
      [
        ("static", Json(self.is_static)),
        ..self.key.fields(),
        ("kind", Json(self.kind)),
        ("value", self.value.encode("FunctionExpression")),
      ],
      self.decorators,
    ),
  )
}

///|
fn MethodDefinition::decode(
  o : Obj,
) -> MethodDefinition raise @json.JsonDecodeError {
  let value = o.child("value")
  value.expect_type("FunctionExpression")
  {
    info: o.info(),
    key: PropertyKey::decode(o),
    value: Function::decode(value),
    kind: o.get("kind"),
    is_static: o.flag("static"),
    decorators: o.list("decorators"),
  }
}

///|
pub impl ToJson for PropertyDefinition with fn to_json(self) {
  node(
    "PropertyDefinition",
    self.info,
    push_decorators(
      [
        ("static", Json(self.is_static)),
        ..self.key.fields(),
        ("value", nullable(self.value)),
      ],
      self.decorators,
    ),
  )
}

///|
fn PropertyDefinition::decode(
  o : Obj,
) -> PropertyDefinition raise @json.JsonDecodeError {
  {
    info: o.info(),
    key: PropertyKey::decode(o),
    value: o.nullable("value"),
    is_static: o.flag("static"),
    decorators: o.list("decorators"),
  }
}

///|
pub impl ToJson for AccessorProperty with fn to_json(self) {
  node(
    "AccessorProperty",
    self.info,
    push_decorators(
      [
        ("static", Json(self.is_static)),
        ..self.key.fields(),
        ("value", nullable(self.value)),
      ],
      self.decorators,
    ),
  )
}

///|
fn AccessorProperty::decode(
  o : Obj,
) -> AccessorProperty raise @json.JsonDecodeError {
  {
    info: o.info(),
    key: PropertyKey::decode(o),
    value: o.nullable("value"),
    is_static: o.flag("static"),
    decorators: o.list("decorators"),
  }
}

///|
pub impl ToJson for StaticBlock with fn to_json(self) {
  node("StaticBlock", self.info, [("body", Json(self.body))])
}

///|
fn StaticBlock::decode(o : Obj) -> StaticBlock raise @json.JsonDecodeError {
  { info: o.info(), body: o.get("body"), }
}

///|
pub impl ToJson for Decorator with fn to_json(self) {
  node("Decorator", self.info, [("expression", Json(self.expression))])
}

///|
pub impl FromJson for Decorator with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("Decorator")
  { info: o.info(), expression: o.get("expression"), }
}
