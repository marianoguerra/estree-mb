///|
pub impl ToJson for Statement with fn to_json(self) {
  match self {
    Expression(x) => Json(x)
    Block(x) => Json(x)
    Empty(info) => node("EmptyStatement", info, [])
    Debugger(info) => node("DebuggerStatement", info, [])
    With(x) => Json(x)
    Return(x) => Json(x)
    Labeled(x) => Json(x)
    Break(x) => Json(x)
    Continue(x) => Json(x)
    If(x) => Json(x)
    Switch(x) => Json(x)
    Throw(x) => Json(x)
    Try(x) => Json(x)
    While(x) => Json(x)
    DoWhile(x) => Json(x)
    For(x) => Json(x)
    ForIn(x) => Json(x)
    ForOf(x) => Json(x)
    Declaration(x) => Json(x)
  }
}

///|
fn Statement::decode(o : Obj) -> Statement raise @json.JsonDecodeError {
  match o.type_() {
    "ExpressionStatement" => Expression(ExpressionStatement::decode(o))
    "BlockStatement" => Block(BlockStatement::decode(o))
    "EmptyStatement" => Empty(o.info())
    "DebuggerStatement" => Debugger(o.info())
    "WithStatement" => With(WithStatement::decode(o))
    "ReturnStatement" => Return(ReturnStatement::decode(o))
    "LabeledStatement" => Labeled(LabeledStatement::decode(o))
    "BreakStatement" => Break(BreakStatement::decode(o))
    "ContinueStatement" => Continue(ContinueStatement::decode(o))
    "IfStatement" => If(IfStatement::decode(o))
    "SwitchStatement" => Switch(SwitchStatement::decode(o))
    "ThrowStatement" => Throw(ThrowStatement::decode(o))
    "TryStatement" => Try(TryStatement::decode(o))
    "WhileStatement" => While(WhileStatement::decode(o))
    "DoWhileStatement" => DoWhile(DoWhileStatement::decode(o))
    "ForStatement" => For(ForStatement::decode(o))
    "ForInStatement" => ForIn(ForInStatement::decode(o))
    "ForOfStatement" => ForOf(ForOfStatement::decode(o))
    "FunctionDeclaration" | "VariableDeclaration" | "ClassDeclaration" =>
      Declaration(Declaration::decode(o))
    other => o.unexpected_type("statement", other)
  }
}

///|
pub impl FromJson for Statement with fn from_json(json, path) {
  Statement::decode(Obj::new(json, path))
}

///|
pub impl ToJson for ExpressionStatement with fn to_json(self) {
  node("ExpressionStatement", self.info, [("expression", Json(self.expression))])
}

///|
fn ExpressionStatement::decode(
  o : Obj,
) -> ExpressionStatement raise @json.JsonDecodeError {
  { info: o.info(), expression: o.get("expression"), }
}

///|
pub impl ToJson for BlockStatement with fn to_json(self) {
  node("BlockStatement", self.info, [("body", Json(self.body))])
}

///|
fn BlockStatement::decode(
  o : Obj,
) -> BlockStatement raise @json.JsonDecodeError {
  { info: o.info(), body: o.get("body"), }
}

///|
pub impl FromJson for BlockStatement with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("BlockStatement")
  BlockStatement::decode(o)
}

///|
pub impl ToJson for WithStatement with fn to_json(self) {
  node("WithStatement", self.info, [
    ("object", Json(self.object)),
    ("body", Json(self.body)),
  ])
}

///|
fn WithStatement::decode(o : Obj) -> WithStatement raise @json.JsonDecodeError {
  { info: o.info(), object: o.get("object"), body: o.get("body"), }
}

///|
pub impl ToJson for ReturnStatement with fn to_json(self) {
  node("ReturnStatement", self.info, [("argument", nullable(self.argument))])
}

///|
fn ReturnStatement::decode(
  o : Obj,
) -> ReturnStatement raise @json.JsonDecodeError {
  { info: o.info(), argument: o.nullable("argument"), }
}

///|
pub impl ToJson for LabeledStatement with fn to_json(self) {
  node("LabeledStatement", self.info, [
    ("body", Json(self.body)),
    ("label", Json(self.label)),
  ])
}

///|
fn LabeledStatement::decode(
  o : Obj,
) -> LabeledStatement raise @json.JsonDecodeError {
  { info: o.info(), label: o.get("label"), body: o.get("body"), }
}

///|
pub impl ToJson for BreakStatement with fn to_json(self) {
  node("BreakStatement", self.info, [("label", nullable(self.label))])
}

///|
fn BreakStatement::decode(
  o : Obj,
) -> BreakStatement raise @json.JsonDecodeError {
  { info: o.info(), label: o.nullable("label"), }
}

///|
pub impl ToJson for ContinueStatement with fn to_json(self) {
  node("ContinueStatement", self.info, [("label", nullable(self.label))])
}

///|
fn ContinueStatement::decode(
  o : Obj,
) -> ContinueStatement raise @json.JsonDecodeError {
  { info: o.info(), label: o.nullable("label"), }
}

///|
pub impl ToJson for IfStatement with fn to_json(self) {
  node("IfStatement", self.info, [
    ("test", Json(self.test_)),
    ("consequent", Json(self.consequent)),
    ("alternate", nullable(self.alternate)),
  ])
}

///|
fn IfStatement::decode(o : Obj) -> IfStatement raise @json.JsonDecodeError {
  {
    info: o.info(),
    test_: o.get("test"),
    consequent: o.get("consequent"),
    alternate: o.nullable("alternate"),
  }
}

///|
pub impl ToJson for SwitchStatement with fn to_json(self) {
  node("SwitchStatement", self.info, [
    ("discriminant", Json(self.discriminant)),
    ("cases", Json(self.cases)),
  ])
}

///|
fn SwitchStatement::decode(
  o : Obj,
) -> SwitchStatement raise @json.JsonDecodeError {
  {
    info: o.info(),
    discriminant: o.get("discriminant"),
    cases: o.get("cases"),
  }
}

///|
pub impl ToJson for SwitchCase with fn to_json(self) {
  node("SwitchCase", self.info, [
    ("consequent", Json(self.consequent)),
    ("test", nullable(self.test_)),
  ])
}

///|
pub impl FromJson for SwitchCase with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("SwitchCase")
  {
    info: o.info(),
    test_: o.nullable("test"),
    consequent: o.get("consequent"),
  }
}

///|
pub impl ToJson for ThrowStatement with fn to_json(self) {
  node("ThrowStatement", self.info, [("argument", Json(self.argument))])
}

///|
fn ThrowStatement::decode(
  o : Obj,
) -> ThrowStatement raise @json.JsonDecodeError {
  { info: o.info(), argument: o.get("argument"), }
}

///|
pub impl ToJson for TryStatement with fn to_json(self) {
  node("TryStatement", self.info, [
    ("block", Json(self.block)),
    ("handler", nullable(self.handler)),
    ("finalizer", nullable(self.finalizer)),
  ])
}

///|
fn TryStatement::decode(o : Obj) -> TryStatement raise @json.JsonDecodeError {
  {
    info: o.info(),
    block: o.get("block"),
    handler: o.nullable("handler"),
    finalizer: o.nullable("finalizer"),
  }
}

///|
pub impl ToJson for CatchClause with fn to_json(self) {
  node("CatchClause", self.info, [
    ("param", nullable(self.param)),
    ("body", Json(self.body)),
  ])
}

///|
pub impl FromJson for CatchClause with fn from_json(json, path) {
  let o = Obj::new(json, path)
  o.expect_type("CatchClause")
  { info: o.info(), param: o.nullable("param"), body: o.get("body"), }
}

///|
pub impl ToJson for WhileStatement with fn to_json(self) {
  node("WhileStatement", self.info, [
    ("test", Json(self.test_)),
    ("body", Json(self.body)),
  ])
}

///|
fn WhileStatement::decode(
  o : Obj,
) -> WhileStatement raise @json.JsonDecodeError {
  { info: o.info(), test_: o.get("test"), body: o.get("body"), }
}

///|
pub impl ToJson for DoWhileStatement with fn to_json(self) {
  node("DoWhileStatement", self.info, [
    ("body", Json(self.body)),
    ("test", Json(self.test_)),
  ])
}

///|
fn DoWhileStatement::decode(
  o : Obj,
) -> DoWhileStatement raise @json.JsonDecodeError {
  { info: o.info(), body: o.get("body"), test_: o.get("test"), }
}

///|
pub impl ToJson for ForInit with fn to_json(self) {
  match self {
    Variable(x) => Json(x)
    Expression(x) => Json(x)
  }
}

///|
pub impl FromJson for ForInit with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "VariableDeclaration" => Variable(VariableDeclaration::decode(o))
    _ => Expression(Expression::decode(o))
  }
}

///|
pub impl ToJson for ForStatement with fn to_json(self) {
  node("ForStatement", self.info, [
    ("init", nullable(self.init)),
    ("test", nullable(self.test_)),
    ("update", nullable(self.update)),
    ("body", Json(self.body)),
  ])
}

///|
fn ForStatement::decode(o : Obj) -> ForStatement raise @json.JsonDecodeError {
  {
    info: o.info(),
    init: o.nullable("init"),
    test_: o.nullable("test"),
    update: o.nullable("update"),
    body: o.get("body"),
  }
}

///|
pub impl ToJson for ForInLeft with fn to_json(self) {
  match self {
    Variable(x) => Json(x)
    Pattern(x) => Json(x)
  }
}

///|
pub impl FromJson for ForInLeft with fn from_json(json, path) {
  let o = Obj::new(json, path)
  match o.type_() {
    "VariableDeclaration" => Variable(VariableDeclaration::decode(o))
    _ => Pattern(Pattern::decode(o))
  }
}

///|
pub impl ToJson for ForInStatement with fn to_json(self) {
  node("ForInStatement", self.info, [
    ("left", Json(self.left)),
    ("right", Json(self.right)),
    ("body", Json(self.body)),
  ])
}

///|
fn ForInStatement::decode(
  o : Obj,
) -> ForInStatement raise @json.JsonDecodeError {
  {
    info: o.info(),
    left: o.get("left"),
    right: o.get("right"),
    body: o.get("body"),
  }
}

///|
pub impl ToJson for ForOfStatement with fn to_json(self) {
  node("ForOfStatement", self.info, [
    ("await", Json(self.is_await)),
    ("left", Json(self.left)),
    ("right", Json(self.right)),
    ("body", Json(self.body)),
  ])
}

///|
fn ForOfStatement::decode(
  o : Obj,
) -> ForOfStatement raise @json.JsonDecodeError {
  {
    info: o.info(),
    left: o.get("left"),
    right: o.get("right"),
    body: o.get("body"),
    is_await: o.flag("await"),
  }
}
