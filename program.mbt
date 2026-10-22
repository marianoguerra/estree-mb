///|
/// `Program`: the root node.
pub(all) struct Program {
  info : NodeInfo
  source_type : SourceType
  /// The directive prologue (`"use strict"` etc.).
  directives : Array[Directive]
  body : Array[ModuleItem]
} derive(Debug, Eq)

///|
/// `Program.sourceType`.
pub(all) enum SourceType {
  Script
  Module
} derive(Debug, Eq)

///|
/// A top-level item: a statement or an import/export declaration.
pub(all) enum ModuleItem {
  Statement(Statement)
  Module(ModuleDeclaration)
} derive(Debug, Eq)

///|
/// `Directive`: an `ExpressionStatement` in a directive prologue.
pub(all) struct Directive {
  info : NodeInfo
  expression : Literal
  /// Raw directive text without quotes, e.g. `use strict`.
  directive : String
} derive(Debug, Eq)

///|
pub fn SourceType::to_string(self : SourceType) -> String {
  match self {
    Script => "script"
    Module => "module"
  }
}

///|
pub fn SourceType::parse(s : StringView) -> SourceType? {
  match s {
    "script" => Some(Script)
    "module" => Some(Module)
    _ => None
  }
}
