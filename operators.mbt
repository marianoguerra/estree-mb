///|
/// `UnaryOperator`.
pub(all) enum UnaryOperator {
  Minus
  Plus
  Not
  BitNot
  Typeof
  Void
  Delete
} derive(Debug, Eq)

///|
pub fn UnaryOperator::to_string(self : UnaryOperator) -> String {
  match self {
    Minus => "-"
    Plus => "+"
    Not => "!"
    BitNot => "~"
    Typeof => "typeof"
    Void => "void"
    Delete => "delete"
  }
}

///|
pub fn UnaryOperator::parse(s : StringView) -> UnaryOperator? {
  match s {
    "-" => Some(Minus)
    "+" => Some(Plus)
    "!" => Some(Not)
    "~" => Some(BitNot)
    "typeof" => Some(Typeof)
    "void" => Some(Void)
    "delete" => Some(Delete)
    _ => None
  }
}

///|
/// `UpdateOperator`.
pub(all) enum UpdateOperator {
  Increment
  Decrement
} derive(Debug, Eq)

///|
pub fn UpdateOperator::to_string(self : UpdateOperator) -> String {
  match self {
    Increment => "++"
    Decrement => "--"
  }
}

///|
pub fn UpdateOperator::parse(s : StringView) -> UpdateOperator? {
  match s {
    "++" => Some(Increment)
    "--" => Some(Decrement)
    _ => None
  }
}

///|
/// `BinaryOperator` (ES5 + `**` from ES2016).
pub(all) enum BinaryOperator {
  Eq
  NotEq
  StrictEq
  StrictNotEq
  Lt
  LtEq
  Gt
  GtEq
  Shl
  Shr
  UShr
  Add
  Sub
  Mul
  Div
  Mod
  Exp
  BitOr
  BitXor
  BitAnd
  In
  Instanceof
} derive(Debug, Eq)

///|
pub fn BinaryOperator::to_string(self : BinaryOperator) -> String {
  match self {
    Eq => "=="
    NotEq => "!="
    StrictEq => "==="
    StrictNotEq => "!=="
    Lt => "<"
    LtEq => "<="
    Gt => ">"
    GtEq => ">="
    Shl => "<<"
    Shr => ">>"
    UShr => ">>>"
    Add => "+"
    Sub => "-"
    Mul => "*"
    Div => "/"
    Mod => "%"
    Exp => "**"
    BitOr => "|"
    BitXor => "^"
    BitAnd => "&"
    In => "in"
    Instanceof => "instanceof"
  }
}

///|
pub fn BinaryOperator::parse(s : StringView) -> BinaryOperator? {
  match s {
    "==" => Some(Eq)
    "!=" => Some(NotEq)
    "===" => Some(StrictEq)
    "!==" => Some(StrictNotEq)
    "<" => Some(Lt)
    "<=" => Some(LtEq)
    ">" => Some(Gt)
    ">=" => Some(GtEq)
    "<<" => Some(Shl)
    ">>" => Some(Shr)
    ">>>" => Some(UShr)
    "+" => Some(Add)
    "-" => Some(Sub)
    "*" => Some(Mul)
    "/" => Some(Div)
    "%" => Some(Mod)
    "**" => Some(Exp)
    "|" => Some(BitOr)
    "^" => Some(BitXor)
    "&" => Some(BitAnd)
    "in" => Some(In)
    "instanceof" => Some(Instanceof)
    _ => None
  }
}

///|
/// `LogicalOperator` (ES5 + `??` from ES2020).
pub(all) enum LogicalOperator {
  Or
  And
  NullishCoalescing
} derive(Debug, Eq)

///|
pub fn LogicalOperator::to_string(self : LogicalOperator) -> String {
  match self {
    Or => "||"
    And => "&&"
    NullishCoalescing => "??"
  }
}

///|
pub fn LogicalOperator::parse(s : StringView) -> LogicalOperator? {
  match s {
    "||" => Some(Or)
    "&&" => Some(And)
    "??" => Some(NullishCoalescing)
    _ => None
  }
}

///|
/// `AssignmentOperator` (ES5 + `**=` from ES2016 + logical assignment from
/// ES2021).
pub(all) enum AssignmentOperator {
  Assign
  AddAssign
  SubAssign
  MulAssign
  DivAssign
  ModAssign
  ExpAssign
  ShlAssign
  ShrAssign
  UShrAssign
  BitOrAssign
  BitXorAssign
  BitAndAssign
  OrAssign
  AndAssign
  NullishAssign
} derive(Debug, Eq)

///|
pub fn AssignmentOperator::to_string(self : AssignmentOperator) -> String {
  match self {
    Assign => "="
    AddAssign => "+="
    SubAssign => "-="
    MulAssign => "*="
    DivAssign => "/="
    ModAssign => "%="
    ExpAssign => "**="
    ShlAssign => "<<="
    ShrAssign => ">>="
    UShrAssign => ">>>="
    BitOrAssign => "|="
    BitXorAssign => "^="
    BitAndAssign => "&="
    OrAssign => "||="
    AndAssign => "&&="
    NullishAssign => "??="
  }
}

///|
pub fn AssignmentOperator::parse(s : StringView) -> AssignmentOperator? {
  match s {
    "=" => Some(Assign)
    "+=" => Some(AddAssign)
    "-=" => Some(SubAssign)
    "*=" => Some(MulAssign)
    "/=" => Some(DivAssign)
    "%=" => Some(ModAssign)
    "**=" => Some(ExpAssign)
    "<<=" => Some(ShlAssign)
    ">>=" => Some(ShrAssign)
    ">>>=" => Some(UShrAssign)
    "|=" => Some(BitOrAssign)
    "^=" => Some(BitXorAssign)
    "&=" => Some(BitAndAssign)
    "||=" => Some(OrAssign)
    "&&=" => Some(AndAssign)
    "??=" => Some(NullishAssign)
    _ => None
  }
}
