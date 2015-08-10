// MARK: Definition

/**
A Trie is a set-like data structure. It stores *sequences* of hashable elements, though.
Lookup, insertion, and deletion are all *O(n)*, where *n* is the length of the sequence.
*/

public struct Trie<Element : Hashable> {
  private var children: [Element:Trie<Element>]
  private var endHere : Bool
  public init() {
    children = [:]
    endHere  = false
  }
}

extension Trie : CustomDebugStringConvertible {
  public var debugDescription: String {
    return ", ".join(map {"".join($0.map { String(reflecting: $0) })})
  }
}

public func ==<T>(lhs: Trie<T>, rhs: Trie<T>) -> Bool {
  return lhs.endHere == rhs.endHere && lhs.children == rhs.children
}

extension Trie : Equatable {}

// MARK: Init

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

extension Trie {
  public init<
    S : SequenceType, IS : SequenceType where
    S.Generator.Element == IS,
    IS.Generator.Element == Element
    >(_ seq: S) {
      var trie = Trie()
      for word in seq { trie.insert(word) }
      self = trie
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

// MARK: SequenceType

public struct TrieGenerator<Element : Hashable> : GeneratorType {
  private var children: DictionaryGenerator<Element, Trie<Element>>
  private var curHead : Element?
  private var curEnd  : Bool = false
  private var innerGen: (() -> [Element]?)?
  private mutating func update() {
    guard let (head, child) = children.next() else { innerGen = nil; return }
    curHead = head
    var g = child.generate()
    innerGen = {g.next()}
    curEnd = child.endHere
  }
  public mutating func next() -> [Element]? {
    for ; innerGen != nil; update() {
      if let next = innerGen!() {
        return [curHead!] + next
      } else if curEnd {
        curEnd = false
        return [curHead!]
      }
    }
    return nil
  }
  private init(_ from: Trie<Element>) {
    children = from.children.generate()
    update()
  }
}

extension Trie: SequenceType {
  public func generate() -> TrieGenerator<Element>  {
    return TrieGenerator(self)
  }
}

// MARK: Methods

extension Trie {
  private func completions
    <G : GeneratorType where G.Element == Element>
    (var start: G) -> Trie<Element> {
      guard let head = start.next() else  { return self }
      guard let child = children[head] else { return Trie() }
      return child
        .completions(start)
        .map { [head] + $0 }
  }
  
  public func completions<S : SequenceType where S.Generator.Element == Element>(start: S) -> Trie<Element> {
    return completions(start.generate())
  }
}

extension Trie {
  private mutating func remove<
    G : GeneratorType where G.Element == Element
    >(var g: G) -> Bool { // Return value signifies whether or not it can be removed
      if let head = g.next() {
        guard children[head]?.remove(g) == true else { return false }
        children.removeValueForKey(head)
        return !endHere && children.isEmpty
      }
      endHere = false
      return children.isEmpty
  }
  public mutating func remove<
    S : SequenceType where S.Generator.Element == Element
    >(seq: S) {
      remove(seq.generate())
  }
}

// MARK: Set Methods

/**
isStrictSubsetOf(_:)
isStrictSupersetOf(_:)
*/

public extension Trie {
  private func contains<
    G : GeneratorType where G.Element == Element
    >(var gen: G) -> Bool {
      guard let head = gen.next() else { return endHere }
      return children[head]?.contains(gen) ?? false
  }
  public func contains
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) -> Bool {
      return contains(seq.generate())
  }
  
  public func exclusiveOr<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    > (sequence: S) -> Trie<Element> {
      var ret = self
      for element in sequence {
        ret.contains(element) ? ret.remove(element) : ret.insert(element)
      }
      return ret
  }
  
  public mutating func exclusiveOrInPlace<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) {
      for element in sequence { contains(element) ? remove(element) : insert(element) }
  }
  
  public func intersect<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Trie<Element> {
      return Trie(sequence.filter(contains))
  }
  
  public mutating func intersectInPlace<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) {
      self = intersect(sequence)
  }
  
  public func isDisjointWith<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Bool { return !sequence.contains(self.contains) }
  
  public func isSupersetOf<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Bool {
      return !sequence.contains { !self.contains($0) }
  }
  
  public func isSubsetOf<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Bool {
      return Trie(sequence).isSupersetOf(self)
  }
  
  public mutating func unionInPlace(with: Trie<Element>) {
    endHere = endHere || with.endHere
    for (head, child) in with.children {
      children[head]?.unionInPlace(child) ?? {children[head] = child}()
    }
  }
  
  public func subtract<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) -> Trie<Element> {
      var result = self
      for element in sequence { result.remove(element) }
      return result
  }
  
  public mutating func subtractInPlace<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) {
      for element in sequence { remove(element) }
  }
  
  public mutating func unionInPlace<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S) { unionInPlace(Trie(sequence)) }
  
  public func union(var with: Trie<Element>) -> Trie<Element> {
    with.unionInPlace(self)
    return with
  }
  
  public func union<
    S : SequenceType where
    S.Generator.Element : SequenceType,
    S.Generator.Element.Generator.Element == Element
    >(sequence: S)  -> Trie<Element> {
      return union(Trie(sequence))
  }
}

// MARK: More effecient implementations

extension Trie {
  public func map<S : SequenceType>(@noescape transform: [Element] -> S) -> Trie<S.Generator.Element> {
    var result = Trie<S.Generator.Element>()
    for seq in self {
      result.insert(transform(seq))
    }
    return result
  }
}

extension Trie {
  public func flatMap<S : SequenceType>(@noescape transform: [Element] -> S?) -> Trie<S.Generator.Element> {
    var result = Trie<S.Generator.Element>()
    for seq in self {
      if let transformed = transform(seq) {
        result.insert(transformed)
      }
    }
    return result
  }
  public func flatMap<T>(@noescape transform: [Element] -> Trie<T>) -> Trie<T> {
    var ret = Trie<T>()
    for seq in self {
      ret.unionInPlace(transform(seq))
    }
    return ret
  }
}

extension Trie {
  public func filter(@noescape includeElement: [Element] -> Bool) -> Trie<Element> {
    var ret = self
    for element in self where !includeElement(element) { ret.remove(element) }
    return ret
  }
}

extension Trie {
  public var count: Int {
    return children.values.reduce(endHere ? 1 : 0) { $0 + $1.count }
  }
}