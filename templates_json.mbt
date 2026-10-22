///|
pub impl ToJson for TemplateLiteral with fn to_json(self) {
  node("TemplateLiteral", self.info, [
    ("expressions", Json(self.expressions)),
    ("quasis", Json(self.quasis)),
  ])
}

///|
fn TemplateLiteral::decode(
  o : Obj,
) -> TemplateLiteral raise @json.JsonDecodeError {
  {
    info: o.info(),
    quasis: o.get("quasis"),
    expressions: o.get("expressions"),
  }
}

///|
pub impl FromJson for TemplateLiteral with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("TemplateLiteral")
  TemplateLiteral::decode(o)
}

///|
pub impl ToJson for TemplateElement with fn to_json(self) {
  node("TemplateElement", self.info, [
    ("value", { "raw": Json(self.raw), "cooked": nullable(self.cooked) }),
    ("tail", Json(self.is_tail)),
  ])
}

///|
pub impl FromJson for TemplateElement with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("TemplateElement")
  let value = o.child("value")
  {
    info: o.info(),
    is_tail: o.flag("tail"),
    cooked: value.nullable("cooked"),
    raw: value.get("raw"),
  }
}

///|
pub impl ToJson for TaggedTemplateExpression with fn to_json(self) {
  node("TaggedTemplateExpression", self.info, [
    ("tag", Json(self.tag)),
    ("quasi", Json(self.quasi)),
  ])
}

///|
fn TaggedTemplateExpression::decode(
  o : Obj,
) -> TaggedTemplateExpression raise @json.JsonDecodeError {
  { info: o.info(), tag: o.get("tag"), quasi: o.get("quasi"), }
}
