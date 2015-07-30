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
    return ", ".join(contents.map {"".join($0.map { String(reflecting: $0) })})
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

extension Trie {
  public var contents: [[Element]] {
    return children.flatMap {
      (head: Element, child: Trie<Element>) -> [[Element]] in
      return child.contents.map { [head] + $0 } + (child.endHere ? [[head]] : [])
    }
  }
}

extension Trie: SequenceType {
  public func generate() -> IndexingGenerator<[[Element]]>  {
    return contents.generate()
  }
}

// MARK: Methods

extension Trie {
  private func completions
    <G : GeneratorType where G.Element == Element>
    (var start: G) -> [[Element]] {
      return start.next().map {
        head in
        children[head]?
          .completions(start)
          .map { [head] + $0 } ?? []
        } ?? contents
  }
  
  public func completions<S : SequenceType where S.Generator.Element == Element>(start: S) -> [[Element]] {
    return completions(start.generate())
  }
}

extension Trie {
  private mutating func remove
    <G : GeneratorType where G.Element == Element>
    (var g: G) -> Bool { // Return value signifies whether or not it can be removed
      if let head = g.next() {
        if children[head]?.remove(g) == true {
          children.removeValueForKey(head)
          return !endHere && children.isEmpty
        } else {
          return false
        }
      } else {
        endHere = false
        return children.isEmpty
      }
  }
  public mutating func remove
    <S : SequenceType where S.Generator.Element == Element>
    (seq: S) {
      remove(seq.generate())
  }
}

// MARK: Set Methods

/**
isStrictSubsetOf(_:)
isStrictSupersetOf(_:)
*/

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
    return Trie<S.Generator.Element>(contents.map(transform))
  }
}

extension Trie {
  public func flatMap<S : SequenceType>(@noescape transform: [Element] -> S?) -> Trie<S.Generator.Element> {
    var ret = Trie<S.Generator.Element>()
    for case let seq? in contents.map(transform) { ret.insert(seq) }
    return ret
  }
  public func flatMap<T>(@noescape transform: [Element] -> Trie<T>) -> Trie<T> {
    var ret = Trie<T>()
    for trie in contents.map(transform) { ret.unionInPlace(trie) }
    return ret
  }
}

extension Trie {
  public func filter(@noescape includeElement: [Element] -> Bool) -> Trie<Element> {
    var ret = self
    for element in contents where !includeElement(element) { ret.remove(element) }
    return ret
  }
}

extension Trie {
  public var count: Int {
    return children.values.reduce(endHere ? 1 : 0) { $0 + $1.count }
  }
}