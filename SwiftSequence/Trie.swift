public struct Trie<Element : Hashable> {
  private var children: [Element:Trie<Element>]
  private var endHere : Bool
  public init() {
    children = [:]
    endHere  = false
  }
}

extension Trie {
  private init<G : GeneratorType where G.Element == Element>(var gen: G) {
    if let head = gen.next() {
      (children, endHere) = ([head:Trie(gen:gen)], false)
    } else {
      (children, endHere) = ([:], true)
    }
  }
}

extension Trie {
  private mutating func insert
    <G : GeneratorType where G.Element == Element>
    (var gen: G) {
      if let head = gen.next() {
        children[head]?.insert(gen) ?? {children[head] = Trie(gen: gen)}()
      } else {
        endHere = true
      }
  }
}

public extension Trie {
  public init
    <S : SequenceType where S.Generator.Element == Element>
    (_ seq: S) {
      self.init(gen: seq.generate())
  }
  public mutating func insert
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) {
      insert(seq.generate())
  }
}

public extension Trie {
  private func contains
    <G : GeneratorType where G.Element == Element>
    (var gen: G) -> Bool {
      return gen.next().map{self.children[$0]?.contains(gen) ?? false} ?? endHere
  }
  public func contains
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) -> Bool {
      return contains(seq.generate())
  }
}

public extension Trie {
  private mutating func remove
    <G : GeneratorType where G.Element == Element>
    (var gen: G) {
      if let head = gen.next() {
        children[head]?.remove(gen)
      } else {
        endHere = false
      }
  }
  public mutating func remove
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) {
      remove(seq.generate())
  }
}

extension Trie {
  public var contents: [[Element]] {
    return children.flatMap {
      (head: Element, child: Trie<Element>) -> [[Element]] in
      return child.contents.map { [head] + $0 } + (child.endHere ? [[head]] : [])
    }
  }
}

extension Trie {
  public init<
    S : SequenceType, IS : SequenceType where
    S.Generator.Element == IS,
    IS.Generator.Element == Element
    >(_ seq: S) {
      self = seq.reduce(Trie()) {
        (var prevs: Trie<Element>, next: IS) in
        prevs.insert(next)
        return prevs
      }
  }
}

extension Trie: SequenceType {
  public func generate() -> IndexingGenerator<[[Element]]>  {
    return contents.generate()
  }
}
