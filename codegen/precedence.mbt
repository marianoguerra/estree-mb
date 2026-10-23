///|
/// Precedence that forces parentheses wherever an operand is checked
/// (astring's `NEEDS_PARENTHESES`).
const NEEDS_PARENS = 17

///|
/// Precedence of `CallExpression` / `MemberExpression`.
const CALL_PRECEDENCE = 19

///|
/// astring's `EXPRESSIONS_PRECEDENCE`. `ImportExpression` and `MetaProperty`
/// are absent from astring's table, which makes them never parenthesized;
/// the maximum precedence reproduces that.
fn precedence(e : Expression) -> Int32 {
  match e {
    Array(_)
    | TaggedTemplate(_)
    | This(_)
    | Identifier(_)
    | Template(_)
    | Sequence(_)
    | Import(_)
    | MetaProperty(_) => 20
    Member(_) | Chain(_) | Call(_) | New(_) => CALL_PRECEDENCE
    Literal(_) => 18
    Arrow(_) | Class(_) | Function(_) | Object(_) => NEEDS_PARENS
    Update(_) => 16
    Unary(_) | Await(_) => 15
    Binary(_) => 14
    Logical(_) => 13
    Conditional(_) => 4
    Assignment(_) => 3
    Yield(_) => 2
  }
}

///|
/// Whether astring's precedence table lists the expression's node type.
fn in_precedence_table(e : Expression) -> Bool {
  !(e is (Import(_) | MetaProperty(_)))
}

///|
/// astring's `OPERATOR_PRECEDENCE`.
fn operator_precedence(op : String) -> Int32 {
  match op {
    "||" => 2
    "??" => 3
    "&&" => 4
    "|" => 5
    "^" => 6
    "&" => 7
    "==" | "!=" | "===" | "!==" => 8
    "<" | ">" | "<=" | ">=" | "in" | "instanceof" => 9
    "<<" | ">>" | ">>>" => 10
    "+" | "-" => 11
    "*" | "%" | "/" => 12
    "**" => 13
    _ => 0
  }
}

///|
/// The operator of a binary, logical or unary expression, `""` otherwise.
fn operator_of(e : Expression) -> String {
  match e {
    Binary(b) => b.operator.to_string()
    Logical(l) => l.operator.to_string()
    Unary(u) => u.operator.to_string()
    _ => ""
  }
}

///|
/// astring's `expressionNeedsParenthesis` for `node` as an operand of a
/// parent with precedence `parent` and operator `parent_op`.
fn needs_parens(
  node : Expression,
  parent : Int32,
  parent_op : String,
  is_right : Bool,
) -> Bool {
  let p = precedence(node)
  if p == NEEDS_PARENS {
    return true
  }
  if p != parent {
    return (!is_right && p == 15 && parent == 14 && parent_op == "**") ||
      p < parent
  }
  if p != 13 && p != 14 {
    return false
  }
  let op = operator_of(node)
  if op == "**" && parent_op == "**" {
    return !is_right
  }
  if p == 13 && (op == "??" || parent_op == "??") {
    return true
  }
  if is_right {
    operator_precedence(op) <= operator_precedence(parent_op)
  } else {
    operator_precedence(op) < operator_precedence(parent_op)
  }
}

///|
/// astring's `hasCallExpression`: a call somewhere along a member chain,
/// which must be parenthesized as a `new` callee.
fn has_call_expression(e : Expression) -> Bool {
  match e {
    Call(_) => true
    Member({ object: Expression(object), .. }) => has_call_expression(object)
    _ => false
  }
}
