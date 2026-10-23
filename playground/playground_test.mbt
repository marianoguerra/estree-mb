///|
test "process returns the re-encoded JSON and generated code" {
  let source =
    #|{"type":"Program","sourceType":"script","body":[
    #|  {"type":"ExpressionStatement","expression":{"type":"Identifier","name":"a"}}]}
  let result = @json.parse(@playground.process(source))
  guard result is { "ok": true, "json": String(json), "code": String(code), .. } else {
    fail("unexpected envelope: \{result.stringify()}")
  }
  inspect(code, content="a;\n")
  assert_eq(@json.parse(json), @json.parse(source))
}

///|
test "process reports decode errors" {
  let result = @json.parse(@playground.process("{\"type\":\"Nope\"}"))
  guard result is { "ok": false, "error": String(error), .. } else {
    fail("unexpected envelope: \{result.stringify()}")
  }
  assert_true(error.length() > 0)
}
