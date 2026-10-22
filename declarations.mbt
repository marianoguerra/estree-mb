///|
/// `Declaration`.
pub(all) enum Declaration {
  /// `FunctionDeclaration`.
  Function(Function)
  Variable(VariableDeclaration)
  /// `ClassDeclaration`.
  Class(Class)
} derive(Debug, Eq)

///|
/// `VariableDeclaration.kind`.
pub(all) enum VariableKind {
  Var
  Let
  Const
  /// ES2026 explicit resource management.
  Using
  AwaitUsing
} derive(Debug, Eq)

///|
pub fn VariableKind::to_string(self : VariableKind) -> String {
  match self {
    Var => "var"
    Let => "let"
    Const => "const"
    Using => "using"
    AwaitUsing => "await using"
  }
}

///|
pub fn VariableKind::parse(s : StringView) -> VariableKind? {
  match s {
    "var" => Some(Var)
    "let" => Some(Let)
    "const" => Some(Const)
    "using" => Some(Using)
    "await using" => Some(AwaitUsing)
    _ => None
  }
}

///|
/// `VariableDeclaration`.
pub(all) struct VariableDeclaration {
  info : NodeInfo
  declarations : Array[VariableDeclarator]
  kind : VariableKind
} derive(Debug, Eq)

///|
/// `VariableDeclarator`.
pub(all) struct VariableDeclarator {
  info : NodeInfo
  id : Pattern
  init : Expression?
} derive(Debug, Eq)
