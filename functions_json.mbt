///|
/// Encodes a function as `FunctionDeclaration` or `FunctionExpression`.
fn Function::encode(self : Function, type_ : String) -> Json {
  node(type_, self.info, [
    ("id", nullable(self.id)),
    ("expression", Json(false)),
    ("generator", Json(self.is_generator)),
    ("async", Json(self.is_async)),
    ("params", Json(self.params)),
    ("body", Json(self.body)),
  ])
}

///|
fn Function::decode(o : Obj) -> Function raise @json.JsonDecodeError {
  {
    info: o.info(),
    id: o.nullable("id"),
    params: o.get("params"),
    body: o.get("body"),
    is_generator: o.flag("generator"),
    is_async: o.flag("async"),
  }
}

///|
/// Splits the leading directive prologue off a statement list.
fn decode_prologue(
  o : Obj,
  key : String,
) -> (Array[Directive], Array[Json], @json.JsonPath, Int32) raise @json.JsonDecodeError {
  let path = o.path.add_key(key)
  guard o.fields.get(key) is Some(Array(items)) else {
    decode_fail(o.path, "missing array field `\{key}`")
  }
  let directives = []
  for i, item in items {
    guard item
      is Object(
        { "type": String("ExpressionStatement"), "directive": String(_), .. }
      ) else {
      return (directives, items, path, i)
    }
    directives.push(Directive::decode(Obj::new(item, path.add_index(i))))
  } nobreak {
    (directives, items, path, items.length())
  }
}

///|
pub impl ToJson for FunctionBody with fn to_json(self) {
  let body : Array[Json] = self.directives.map(d => Json(d))
  for statement in self.body {
    body.push(Json(statement))
  }
  node("BlockStatement", self.info, [("body", Json::array(body))])
}

///|
pub impl FromJson for FunctionBody with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("BlockStatement")
  let (directives, items, items_path, first) = decode_prologue(o, "body")
  let body : Array[Statement] = []
  for i in first..<items.length() {
    body.push(FromJson::from_json(items[i], items_path.add_index(i)))
  }
  { info: o.info(), directives, body, }
}

///|
pub impl ToJson for ArrowFunctionExpression with fn to_json(self) {
  let (expression, body) = match self.body {
    Block(x) => (false, Json(x))
    Expression(x) => (true, Json(x))
  }
  node("ArrowFunctionExpression", self.info, [
    ("id", Json::null()),
    ("expression", Json(expression)),
    ("generator", Json(false)),
    ("async", Json(self.is_async)),
    ("params", Json(self.params)),
    ("body", body),
  ])
}

///|
fn ArrowFunctionExpression::decode(
  o : Obj,
) -> ArrowFunctionExpression raise @json.JsonDecodeError {
  let body = o.child("body")
  {
    info: o.info(),
    params: o.get("params"),
    body: if body.type_() == "BlockStatement" {
      Block(o.get("body"))
    } else {
      Expression(Expression::decode(body))
    },
    is_async: o.flag("async"),
  }
}
