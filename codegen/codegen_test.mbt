///|
fn expr(source : String) -> @estree.Expression raise {
  @json.from_json(@json.parse(source))
}

///|
fn ident(name : String) -> @estree.Expression {
  Identifier(@estree.Identifier::named(name))
}

///|
fn literal(value : @estree.LiteralValue) -> @estree.Expression {
  Literal({ info: @estree.NodeInfo::empty(), value, raw: None, })
}

///|
test "literals without raw use canonical spellings" {
  let values : Array[@estree.LiteralValue] = [
    String("tab\t \"quote\" back\\slash \u{1}"),
    String("emoji 😀"),
    Number(1.0e21),
    Number(0.1),
    Number(-0.0),
    Number(100.0),
    Boolean(true),
    Null,
    RegExp(pattern="a+", flags="gu"),
    BigInt("12"),
  ]
  inspect(
    values.map(v => @codegen.expression(literal(v))).join("\n"),
    content=(
      #|"tab\t \"quote\" back\\slash \u0001"
      #|"emoji 😀"
      #|1e+21
      #|0.1
      #|0
      #|100
      #|true
      #|null
      #|/a+/gu
      #|12n
    ),
  )
}

///|
test "raw text wins over the value" {
  let e : @estree.Expression = Literal({
    info: @estree.NodeInfo::empty(),
    value: Number(255.0),
    raw: Some("0xFF"),
  })
  inspect(@codegen.expression(e), content="0xFF")
}

///|
test "lone surrogates are escaped" {
  let lone = String::from_array([Int32::unsafe_to_char(0xD800)])
  inspect(@codegen.expression(literal(String(lone))), content="\"\\ud800\"")
}

///|
test "indent and line end options" {
  let program = @estree.Program::parse_json(
    (
      #|{"type":"Program","sourceType":"script","body":[
      #|  {"type":"ExpressionStatement","directive":"use strict",
      #|   "expression":{"type":"Literal","value":"use strict","raw":"'use strict'"}},
      #|  {"type":"IfStatement","test":{"type":"Identifier","name":"a"},
      #|   "consequent":{"type":"BlockStatement","body":[
      #|     {"type":"ReturnStatement","argument":null}]},"alternate":null}]}
    ),
  )
  inspect(
    @codegen.program(program),
    content=(
      #|'use strict';
      #|if (a) {
      #|  return;
      #|}
      #|
    ),
  )
  inspect(
    @codegen.program(program, indent="\t", line_end="\r\n").escape(),
    content=(
      #|"'use strict';\r\nif (a) {\r\n\treturn;\r\n}\r\n"
    ),
  )
}

///|
test "decorators are parenthesized unless they are dotted calls" {
  let class_with = (decorator : String) => {
    let source = "{\"type\":\"ClassExpression\",\"id\":null,\"superClass\":null," +
      "\"decorators\":[{\"type\":\"Decorator\",\"expression\":\{decorator}}]," +
      "\"body\":{\"type\":\"ClassBody\",\"body\":[]}}"
    @codegen.expression(expr(source))
  }
  let dotted =
    #|{"type":"MemberExpression","computed":false,
    #| "object":{"type":"Identifier","name":"a"},
    #| "property":{"type":"Identifier","name":"b"}}
  let call = "{\"type\":\"CallExpression\",\"callee\":\{dotted},\"arguments\":[]}"
  let conditional =
    #|{"type":"ConditionalExpression","test":{"type":"Identifier","name":"a"},
    #| "consequent":{"type":"Identifier","name":"b"},
    #| "alternate":{"type":"Identifier","name":"c"}}
  inspect(class_with(dotted), content="@a.b class {}")
  inspect(class_with(call), content="@a.b() class {}")
  inspect(class_with(conditional), content="@(a ? b : c) class {}")
}

///|
test "statements starting with `let [` are parenthesized" {
  let s : @estree.Statement = Expression({
    info: @estree.NodeInfo::empty(),
    expression: Member({
      info: @estree.NodeInfo::empty(),
      object: Expression(ident("let")),
      property: Computed(ident("x")),
      is_optional: false,
    }),
  })
  inspect(@codegen.statement(s), content="(let[x]);")
}

///|
test "chain expressions end the chain with parentheses" {
  let chain =
    #|{"type":"ChainExpression","expression":{"type":"MemberExpression",
    #| "optional":true,"computed":false,
    #| "object":{"type":"Identifier","name":"a"},
    #| "property":{"type":"Identifier","name":"b"}}}
  let source = "{\"type\":\"MemberExpression\",\"computed\":false,\"object\":\{chain}," +
    "\"property\":{\"type\":\"Identifier\",\"name\":\"c\"}}"
  inspect(@codegen.expression(expr(source)), content="(a?.b).c")
  inspect(@codegen.expression(expr(chain)), content="a?.b")
}

///|
test "oracle check reports the first differing line" {
  let source =
    #|{"type":"Program","sourceType":"script","body":[
    #|  {"type":"ExpressionStatement","expression":{"type":"Identifier","name":"a"}}]}
  let oracle =
    #|{"program":"b;\n","items":[{"code":"b;\n","trusted":true}]}
  try check_oracle(source, oracle) catch {
    err => {
      let message = err.to_string()
      assert_true(message.contains("program, line 1:"))
      assert_true(message.contains("astring: b;\n  ours:    a;"))
    }
  } noraise {
    _ => fail("expected an oracle mismatch")
  }
}
