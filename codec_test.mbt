///|
fn decode_error(source : String) -> String {
  try @estree.Program::parse_json(source) catch {
    err => err.to_string()
  } noraise {
    _ => "decoded without error"
  }
}

///|
fn ident(name : String) -> @estree.Expression {
  Identifier(@estree.Identifier::named(name))
}

///|
fn statement(expression : @estree.Expression) -> @estree.ModuleItem {
  Statement(Expression({ info: @estree.NodeInfo::empty(), expression, }))
}

///|
fn program(body : Array[@estree.ModuleItem]) -> @estree.Program {
  {
    info: @estree.NodeInfo::empty(),
    source_type: Module,
    directives: [],
    body,
  }
}

///|
test "roundtrip harness rejects lossy input" {
  // `extra` is not modeled, so the roundtrip must report it as missing.
  let source =
    #|{"type":"Program","sourceType":"script","body":[],"extra":1}
  try assert_roundtrip(source) catch {
    err =>
      inspect(
        err,
        content=(
          #|Failure(roundtrip_test.mbt:50:5-50:42@marianoguerra/estree FAILED: roundtrip mismatch at $.extra: missing in output)
        ),
      )
  } noraise {
    _ => fail("expected a roundtrip mismatch")
  }
}

///|
test "json_diff pinpoints the first difference" {
  let a = @json.parse("{\"a\":[1,{\"b\":2}]}")
  let b = @json.parse("{\"a\":[1,{\"b\":3}]}")
  debug_inspect(json_diff(a, b, "$"), content="Some(\"$.a[1].b: 2 != 3\")")
  debug_inspect(json_diff(a, a, "$"), content="None")
}

///|
test "computed flag is folded into member and property keys" {
  let access : @estree.Expression = Member({
    info: @estree.NodeInfo::empty(),
    object: Expression(ident("a")),
    property: Computed(ident("b")),
    is_optional: false,
  })
  let object : @estree.Expression = Object({
    info: @estree.NodeInfo::empty(),
    properties: [
      Property({
        info: @estree.NodeInfo::empty(),
        key: Computed(ident("k")),
        value: ident("v"),
        kind: Init,
        is_method: false,
        is_shorthand: false,
      }),
    ],
  })
  json_inspect(access, content={
    "type": "MemberExpression",
    "object": { "type": "Identifier", "name": "a" },
    "property": { "type": "Identifier", "name": "b" },
    "computed": true,
    "optional": false,
  })
  json_inspect(object, content={
    "type": "ObjectExpression",
    "properties": [
      {
        "type": "Property",
        "method": false,
        "shorthand": false,
        "computed": true,
        "key": { "type": "Identifier", "name": "k" },
        "value": { "type": "Identifier", "name": "v" },
        "kind": "init",
      },
    ],
  })
}

///|
test "directives are emitted before the body" {
  let p : @estree.Program = {
    ..program([statement(ident("x"))]),
    directives: [
      {
        info: @estree.NodeInfo::empty(),
        expression: @estree.Literal::string("use strict"),
        directive: "use strict",
      },
    ],
  }
  json_inspect(p, content={
    "type": "Program",
    "body": [
      {
        "type": "ExpressionStatement",
        "expression": { "type": "Literal", "value": "use strict" },
        "directive": "use strict",
      },
      {
        "type": "ExpressionStatement",
        "expression": { "type": "Identifier", "name": "x" },
      },
    ],
    "sourceType": "module",
  })
}

///|
test "regexp and bigint literals encode value as null" {
  let regex : @estree.Literal = {
    info: @estree.NodeInfo::empty(),
    value: RegExp(pattern="a+", flags="g"),
    raw: Some("/a+/g"),
  }
  let bigint : @estree.Literal = {
    info: @estree.NodeInfo::empty(),
    value: BigInt("10"),
    raw: Some("10n"),
  }
  json_inspect(regex, content={
    "type": "Literal",
    "value": null,
    "raw": "/a+/g",
    "regex": { "pattern": "a+", "flags": "g" },
  })
  json_inspect(bigint, content={
    "type": "Literal",
    "value": null,
    "raw": "10n",
    "bigint": "10",
  })
}

///|
test "positions are decoded into NodeInfo" {
  let p = @estree.Program::parse_json(
    (
      #|{"type":"Program","start":0,"end":1,"range":[0,1],
      #| "loc":{"source":"a.js","start":{"line":1,"column":0},"end":{"line":1,"column":1}},
      #| "sourceType":"script","body":[]}
    ),
  )
  debug_inspect(
    p.info,
    content=(
      #|{
      #|  loc: Some(
      #|    {
      #|      source: Some("a.js"),
      #|      start: { line: 1, column: 0 },
      #|      end: { line: 1, column: 1 },
      #|    },
      #|  ),
      #|  start: Some(0),
      #|  end: Some(1),
      #|  range: Some((0, 1)),
      #|}
    ),
  )
}

///|
test "decoded AST is idiomatic to pattern match" {
  let p = @estree.Program::parse_json(
    (
      #|{"type":"Program","sourceType":"module","body":[
      #|  {"type":"ExpressionStatement","directive":"use strict",
      #|   "expression":{"type":"Literal","value":"use strict"}},
      #|  {"type":"ExpressionStatement","expression":{"type":"ChainExpression",
      #|   "expression":{"type":"MemberExpression","optional":true,"computed":false,
      #|    "object":{"type":"Identifier","name":"a"},
      #|    "property":{"type":"Identifier","name":"b"}}}}]}
    ),
  )
  inspect(p.directives[0].directive, content="use strict")
  guard p.body
    is [
      Statement(
        Expression(
          {
            expression: Chain(
              {
                expression: Member(
                  {
                    object: Expression(Identifier({ name: "a", .. })),
                    property: Identifier({ name: "b", .. }),
                    is_optional: true,
                    ..
                  }
                ),
                ..
              }
            ),
            ..
          }
        )
      ),
    ] else {
    fail("unexpected AST shape")
  }
}

///|
test "decode errors report the JSON path" {
  inspect(
    decode_error("{\"type\":\"Program\",\"body\":[{\"type\":\"Nope\"}]}"),
    content=(
      #|JsonDecodeError((/body/0/type, unexpected statement type `Nope`))
    ),
  )
  inspect(
    decode_error(
      "{\"type\":\"Program\",\"body\":[{\"type\":\"ExpressionStatement\"}]}",
    ),
    content=(
      #|JsonDecodeError((/body/0, missing field `expression`))
    ),
  )
  inspect(
    decode_error(
      (
        #|{"type":"Program","body":[{"type":"ExpressionStatement","expression":
        #| {"type":"BinaryExpression","operator":"<=>",
        #|  "left":{"type":"Identifier","name":"a"},
        #|  "right":{"type":"Identifier","name":"b"}}}]}
      ),
    ),
    content=(
      #|JsonDecodeError((/body/0/expression/operator, invalid binary operator: `<=>`))
    ),
  )
  inspect(
    decode_error(
      "{\"type\":\"Program\",\"body\":[{\"type\":\"VariableDeclaration\",\"kind\":\"val\",\"declarations\":[]}]}",
    ),
    content=(
      #|JsonDecodeError((/body/0/kind, invalid variable kind: `val`))
    ),
  )
  inspect(
    decode_error("{\"type\":\"Script\",\"body\":[]}"),
    content=(
      #|JsonDecodeError((/type, expected node type `Program`, got `Script`))
    ),
  )
  inspect(
    decode_error("[1, 2"),
    content=(
      #|Unexpected end of file
    ),
  )
}

///|
test "operators roundtrip through their ESTree spelling" {
  for op in ["==", "!==", ">>>", "**", "in", "instanceof"] {
    guard @estree.BinaryOperator::parse(op) is Some(parsed) else {
      fail("cannot parse \{op}")
    }
    assert_eq(parsed.to_string(), op)
  }
  for op in ["=", "**=", ">>>=", "||=", "&&=", "??="] {
    guard @estree.AssignmentOperator::parse(op) is Some(parsed) else {
      fail("cannot parse \{op}")
    }
    assert_eq(parsed.to_string(), op)
  }
  debug_inspect(
    @estree.LogicalOperator::parse("??"),
    content=(
      #|Some(NullishCoalescing)
    ),
  )
  debug_inspect(
    @estree.VariableKind::parse("await using"),
    content=(
      #|Some(AwaitUsing)
    ),
  )
  debug_inspect(
    @estree.UnaryOperator::parse("+="),
    content=(
      #|None
    ),
  )
}
