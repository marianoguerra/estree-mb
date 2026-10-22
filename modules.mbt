///|
/// `ImportOrExportDeclaration`.
pub(all) enum ModuleDeclaration {
  Import(ImportDeclaration)
  ExportNamed(ExportNamedDeclaration)
  ExportDefault(ExportDefaultDeclaration)
  ExportAll(ExportAllDeclaration)
} derive(Debug, Eq)

///|
/// Stage 3 import phase: `import source x from "m"` / `import defer * as x`.
pub(all) enum ImportPhase {
  Source
  Defer
} derive(Debug, Eq)

///|
pub fn ImportPhase::to_string(self : ImportPhase) -> String {
  match self {
    Source => "source"
    Defer => "defer"
  }
}

///|
pub fn ImportPhase::parse(s : StringView) -> ImportPhase? {
  match s {
    "source" => Some(Source)
    "defer" => Some(Defer)
    _ => None
  }
}

///|
/// A module export name: an identifier or (ES2022) a string literal.
pub(all) enum ModuleExportName {
  Identifier(Identifier)
  Literal(Literal)
} derive(Debug, Eq)

///|
/// `ImportDeclaration`.
pub(all) struct ImportDeclaration {
  info : NodeInfo
  specifiers : Array[ImportClause]
  source : Literal
  /// ES2025 import attributes (`with { type: "json" }`).
  attributes : Array[ImportAttribute]
  phase : ImportPhase?
} derive(Debug, Eq)

///|
/// One import specifier.
pub(all) enum ImportClause {
  /// `ImportSpecifier`: `{ imported as local }`.
  Named(ImportSpecifier)
  /// `ImportDefaultSpecifier`: `local`.
  Default(ImportDefaultSpecifier)
  /// `ImportNamespaceSpecifier`: `* as local`.
  Namespace(ImportNamespaceSpecifier)
} derive(Debug, Eq)

///|
/// `ImportSpecifier`.
pub(all) struct ImportSpecifier {
  info : NodeInfo
  imported : ModuleExportName
  local_ : Identifier
} derive(Debug, Eq)

///|
/// `ImportDefaultSpecifier`.
pub(all) struct ImportDefaultSpecifier {
  info : NodeInfo
  local_ : Identifier
} derive(Debug, Eq)

///|
/// `ImportNamespaceSpecifier`.
pub(all) struct ImportNamespaceSpecifier {
  info : NodeInfo
  local_ : Identifier
} derive(Debug, Eq)

///|
/// `ImportAttribute` (ES2025).
pub(all) struct ImportAttribute {
  info : NodeInfo
  key : ModuleExportName
  value : Literal
} derive(Debug, Eq)

///|
/// `ExportNamedDeclaration`.
pub(all) struct ExportNamedDeclaration {
  info : NodeInfo
  declaration : Declaration?
  specifiers : Array[ExportSpecifier]
  source : Literal?
  attributes : Array[ImportAttribute]
} derive(Debug, Eq)

///|
/// `ExportSpecifier`.
pub(all) struct ExportSpecifier {
  info : NodeInfo
  local_ : ModuleExportName
  exported : ModuleExportName
} derive(Debug, Eq)

///|
/// `ExportDefaultDeclaration`.
pub(all) struct ExportDefaultDeclaration {
  info : NodeInfo
  declaration : ExportDefaultKind
} derive(Debug, Eq)

///|
/// What an `export default` exports.
pub(all) enum ExportDefaultKind {
  /// A `FunctionDeclaration`, possibly anonymous.
  Function(Function)
  /// A `ClassDeclaration`, possibly anonymous.
  Class(Class)
  Expression(Expression)
} derive(Debug, Eq)

///|
/// `ExportAllDeclaration`: `export * [as exported] from source`.
pub(all) struct ExportAllDeclaration {
  info : NodeInfo
  exported : ModuleExportName?
  source : Literal
  attributes : Array[ImportAttribute]
} derive(Debug, Eq)
