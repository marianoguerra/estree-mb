///|
/// A line/column position in the source text.
///
/// `line` is 1-based and `column` is 0-based, as in the ESTree spec.
pub(all) struct Position {
  line : Int32
  column : Int32
} derive(Debug, Eq)

///|
/// The source span covered by a node (`Node.loc` in ESTree).
pub(all) struct SourceLocation {
  source : String?
  start : Position
  end : Position
} derive(Debug, Eq)

///|
/// Positional information shared by every node.
///
/// `loc` is the spec's `SourceLocation`. `start`, `end` and `range` are the
/// widespread non-spec offsets emitted by acorn, espree and friends; they are
/// kept so that real-world parser output roundtrips without loss.
pub(all) struct NodeInfo {
  loc : SourceLocation?
  start : Int32?
  end : Int32?
  range : (Int32, Int32)?
} derive(Debug, Eq)

///|
/// A `NodeInfo` with no positional information, handy when building ASTs by
/// hand.
pub fn NodeInfo::empty() -> NodeInfo {
  { loc: None, start: None, end: None, range: None, }
}

///|
pub impl Default for NodeInfo with fn default() {
  NodeInfo::empty()
}
