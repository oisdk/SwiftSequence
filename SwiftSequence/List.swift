// MARK: Definition

public enum List<Element> {
  case Nil
  indirect case Cons(head: Element, tail: List<Element>)
}

extension List : CustomDebugStringConvertible {
  public var debugDescription: String {
    return ", ".join(map{String(reflecting: $0)})
  }
}

// MARK: Init

infix operator |> {
  associativity right
  precedence 100
}

public func |> <T>(lhs: T, rhs: List<T>) -> List<T> {
  return .Cons(head: lhs, tail: rhs)
}
extension List {
  private init<G : GeneratorType where G.Element == Element>(var gen: G) {
    if let head = gen.next() {
      self = head |> List(gen: gen)
    } else {
      self = .Nil
    }
  }
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self = List(gen: seq.generate())
  }
}

extension List : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    self = List(arrayLiteral.generate())
  }
}

// MARK: SequenceType

public struct ListGenerator<Element> : GeneratorType, SequenceType {
  private var list: List<Element>
  public mutating func next() -> Element? {
    switch list {
    case .Nil: return nil
    case let .Cons(head, tail):
      list = tail
      return head
    }
  }
  public func generate() -> ListGenerator { return self }
}

extension List : SequenceType {
  public func generate() -> ListGenerator<Element> {
    return ListGenerator(list: self)
  }
}

// MARK: Indexable

extension List {
  public func replacedWith(val: Element, atIndex n: Int) -> List<Element> {
    switch (n, self) {
    case (0, .Cons(_, let tail)): return val |> tail
    case (_, let .Cons(head, tail)): return head |> tail.replacedWith(val, atIndex: n - 1)
    case (_, .Nil): fatalError("Index out of range")
    }
  }
}

// Crashes if made conform to CollectionType for some reason

extension List : Indexable {
  public var startIndex: Int { return 0 }
  public var count: Int {
    switch self {
    case .Nil: return 0
    case .Cons(_, let tail): return tail.count.successor()
    }
  }
  public var endIndex: Int { return count }
  public subscript(n: Int) -> Element {
    get {
      switch (n, self) {
      case (0, .Cons(let head, _)): return head
      case (_, .Cons(_, let tail)): return tail[n - 1]
      case (_, .Nil): fatalError("Index out of range")
      }
    } set {
      self = replacedWith(newValue, atIndex: n)
    }
  }
}

// MARK: More effecient implementations

extension List {
  public func prepended(with: Element) -> List<Element> {
    return with |> self
  }
  public func appended(with: Element) -> List<Element> {
    switch self {
    case .Nil: return [with]
    case let .Cons(head, tail): return head |> tail.appended(with)
    }
  }
  public func extended(with: List<Element>) -> List<Element> {
    switch self {
    case .Nil: return with
    case let .Cons(head, tail): return head |> tail.extended(with)
    }
  }
  public func extended<
    S : SequenceType where
    S.Generator.Element == Element
    >(with: S) -> List<Element> {
      return extended(List(with))
  }
}

extension List {
  public func drop(n: Int) -> List<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return self
    case let (_, .Cons(_, tail)): return tail.drop(n - 1)
    }
  }
  public func take(n: Int) -> List<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return .Nil
    case let (_, .Cons(head, tail)): return head |> tail.take(n - 1)
    }
  }
  public subscript (idxs: Range<Int>) -> List<Element> {
    return drop(idxs.startIndex).take(idxs.endIndex - idxs.startIndex)
  }
}

public extension List {
  public var isEmpty: Bool {
    switch self {
    case .Nil:  return true
    case .Cons: return false
    }
  }
  public var first: Element? {
    switch self {
    case .Nil: return nil
    case let .Cons(head, _): return head
    }
  }
  public var last: Element? {
    switch self {
    case .Nil: return nil
    case let .Cons(head, tail): return tail.isEmpty ? head : tail.last
    }
  }
}

extension List {
  public func map<T>(@noescape transform: Element -> T) -> List<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return transform(head) |> tail.map(transform)
    }
  }
  public func flatMap<T>(@noescape transform: Element -> List<T>) -> List<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return transform(head).extended(tail.flatMap(transform))
    }
  }
  public func flatMap<S : SequenceType>(@noescape transform: Element -> S) -> List<S.Generator.Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return List<S.Generator.Element>(transform(head)).extended(tail.flatMap(transform))
    }
  }
  public func flatMap<T>(@noescape transform: Element -> T?) -> List<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      return transform(head).map { $0 |> tail.flatMap(transform) } ?? tail.flatMap(transform)
    }
  }
}

extension List {
  public var tail: List<Element> {
    switch self {
    case .Nil: fatalError("Cannot call tail on an empty list")
    case let .Cons(_, t): return t
    }
  }
  public mutating func removeFirst() -> Element {
    switch self {
    case .Nil: fatalError("Cannot call removeFirst() on an empty list")
    case let .Cons(head, tail):
      self = tail
      return head
    }
  }
}

extension List {
  public func filter(@noescape includeElement: Element -> Bool) -> List<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      return includeElement(head) ?
        head |> tail.filter(includeElement) :
        tail.filter(includeElement)
    }
  }
}

extension List {
  private func reverse(other: List<Element>) -> List<Element> {
    switch self {
    case .Nil: return other
    case let .Cons(head, tail): return tail.reverse(head |> other)
    }
  }
  public func reverse() -> List<Element> {
    return reverse(.Nil)
  }
}