// MARK: Definition

public enum LazyList<Element> {
  case Nil
  indirect case Cons(head: Element, tail: () -> LazyList<Element>)
}

extension LazyList : CustomDebugStringConvertible {
  public var debugDescription: String {
    return "[:" + ", ".join(map{String(reflecting: $0)}) + ":]"
  }
}

// MARK: Init

public func |> <T>(lhs: T, @autoclosure(escaping) rhs: () -> LazyList<T>) -> LazyList<T> {
  return .Cons(head: lhs, tail: rhs)
}

public extension LazyList {
  private init<G : GeneratorType where G.Element == Element>(var gen: G) {
    if let head = gen.next() {
      self = head |> LazyList(gen: gen)
    } else {
      self = .Nil
    }
  }
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self = LazyList(gen: seq.generate())
  }
}

extension LazyList : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    self = LazyList(arrayLiteral.generate())
  }
}

// MARK: SequenceType

public struct LazyListGenerator<Element> : GeneratorType, LazySequenceType {
  private var current: LazyList<Element>
  public mutating func next() -> Element? {
    switch current {
    case .Nil: return nil
    case let .Cons(head, tail):
      current = tail()
      return head
    }
  }
  public func generate() -> LazyListGenerator { return self }
}

extension LazyList : LazySequenceType {
  public func generate() -> LazyListGenerator<Element> {
    return LazyListGenerator(current: self)
  }
}

// MARK: Indexable

extension LazyList {
  public func replacedWith(val: Element, atIndex n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, .Cons(_, let tail)): return val |> tail()
    case (_, let .Cons(head, tail)): return head |> tail().replacedWith(val, atIndex: n - 1)
    case (_, .Nil): fatalError("Index out of range")
    }
  }
}

// Crashes if made conform to CollectionType for some reason

extension LazyList : Indexable {
  public var startIndex: Int { return 0 }
  public var count: Int {
    switch self {
    case .Nil: return 0
    case .Cons(_, let tail): return 1 + tail().count
    }
  }
  public var endIndex: Int { return count }
  public subscript(n: Int) -> Element {
    get {
      switch (n, self) {
      case (0, .Cons(let head, _)): return head
      case (_, .Cons(_, let tail)): return tail()[n - 1]
      case (_, .Nil): fatalError("Index out of range")
      }
    } set {
      self = replacedWith(newValue, atIndex: n)
    }
  }
}

// MARK: More effecient implementations

extension LazyList {
  public func prepended(with: Element) -> LazyList<Element> {
    return with |> self
  }
  public func appended(@autoclosure(escaping) with: () -> Element) -> LazyList<Element> {
    switch self {
    case .Nil: return .Cons(head: with(), tail: {.Nil})
    case let .Cons(head, tail): return head |> tail().appended(with)
    }
  }
  public func extended(@autoclosure(escaping) with: () -> LazyList<Element>) -> LazyList<Element> {
    switch self {
    case .Nil: return with()
    case let .Cons(head, tail): return head |> tail().extended(with)
    }
  }
  public func extended<
    S : SequenceType where
    S.Generator.Element == Element
    >(@autoclosure(escaping) with: () -> S) -> LazyList<Element> {
      return extended(LazyList(with()))
  }
}

extension LazyList {
  public func drop(n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return self
    case let (_, .Cons(_, tail)): return tail().drop(n - 1)
    }
  }
  public func take(n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, _), (_, .Nil): return .Nil
    case let (_, .Cons(head, tail)): return head |> tail().take(n - 1)
    }
  }
  public subscript (idxs: Range<Int>) -> LazyList<Element> {
    return drop(idxs.startIndex).take(idxs.endIndex - idxs.startIndex)
  }
}

public extension LazyList {
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
    case let .Cons(head, tail): return tail().isEmpty ? head : tail().last
    }
  }
}

extension LazyList {
  public func map<T>(transform: Element -> T) -> LazyList<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return transform(head) |> tail().map(transform)
    }
  }
  public func flatMap<T>(transform: Element -> LazyList<T>) -> LazyList<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return transform(head).extended(tail().flatMap(transform))
    }
  }
  public func flatMap<S : SequenceType>(transform: Element -> S) -> LazyList<S.Generator.Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return LazyList<S.Generator.Element>(transform(head)).extended(tail().flatMap(transform))
    }
  }
  public func flatMap<T>(transform: Element -> T?) -> LazyList<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      return transform(head).map { $0 |> tail().flatMap(transform) } ?? tail().flatMap(transform)
    }
  }
}

extension LazyList {
  public var tail: LazyList<Element> {
    switch self {
    case .Nil: fatalError("Cannot call tail on an empty LazyList")
    case let .Cons(_, t): return t()
    }
  }
  public mutating func removeFirst() -> Element {
    switch self {
    case .Nil: fatalError("Cannot call removeFirst() on an empty LazyList")
    case let .Cons(head, tail):
      self = tail()
      return head
    }
  }
}

extension LazyList {
  public func filter(includeElement: Element -> Bool) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      return includeElement(head) ?
        head |> tail().filter(includeElement) :
        tail().filter(includeElement)
    }
  }
}

extension LazyList {
  private func reverse(other: LazyList<Element>) -> LazyList<Element> {
    switch self {
    case .Nil: return other
    case let .Cons(head, tail): return tail().reverse(head |> other)
    }
  }
  public func reverse() -> LazyList<Element> {
    return reverse(.Nil)
  }
}