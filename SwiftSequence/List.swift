public enum List<Element> {
  case Nil
  indirect case Cons(head: Element, tail: List<Element>)
}

public struct ListGenerator<Element> : GeneratorType {
  private var list: List<Element>
  public mutating func next() -> Element? {
    switch list {
    case .Nil: return nil
    case .Cons(let element, let rest):
      list = rest
      return element
    }
  }
}

extension ListGenerator : SequenceType {
  public func generate() -> ListGenerator {
    return self
  }
}

extension List : SequenceType {
  public func generate() -> ListGenerator<Element> {
    return ListGenerator(list: self)
  }
}

public extension List {
  public var isEmpty: Bool {
		switch self {
    case .Nil:  return true
    case .Cons: return false
    }
  }
}

extension EmptyCollection : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    assert(arrayLiteral.isEmpty)
  }
}

public func ~= <C : CollectionType>
  (lhs: EmptyCollection<C.Generator.Element>, rhs: C) -> Bool {
    return rhs.isEmpty
}

public func ~= <T> (lhs: EmptyCollection<T>, rhs: List<T>) -> Bool {
  switch rhs {
  case .Cons: return false
  default:    return true
  }
}

extension List : ArrayLiteralConvertible {
  public init<G : GeneratorType where G.Element == Element>(var _ gen: G) {
    self = gen.next().map {.Cons(head: $0, tail: List(gen))} ?? .Nil
  }
  public init<S : SequenceType where S.Generator.Element == Element>(seq: S) {
    self = List(seq.generate())
  }
  public init(arrayLiteral: Element...) {
    self = List(arrayLiteral.generate())
  }
}

infix operator |> {
  associativity right
  precedence 90
}

public func |> <T>(lhs: T, rhs: List<T>) -> List<T> {
  return List.Cons(head: lhs, tail: rhs)
}

public extension List {
  public func appended(with: Element) -> List<Element> {
    switch self {
    case .Nil: return [with]
    case .Cons(let head, let tail): return head |> tail.appended(with)
    }
  }
  public func extended(with: List<Element>) -> List<Element> {
    switch self {
    case .Nil: return with
    case .Cons(let head, let tail): return head |> tail.extended(with)
    }
  }
  public func extended<
    S : SequenceType where S.Generator.Element == Element
    >(with: S) -> List<Element> {
      return extended(List(seq: with))
  }
}

extension List : Indexable {
  public var startIndex: Int { return 0 }
  public var endIndex: Int {
    switch self {
    case .Nil: return 0
    case .Cons(_, let tail): return tail.endIndex.successor()
    }
  }
  
  public func with(val: Element, atIndex n: Int) -> List<Element> {
    switch (n, self) {
    case (0, .Cons(_, let tail)): return val |> tail
    case (_, .Cons(let head, let tail)): return head |> tail.with(val, atIndex: n - 1)
    case (_, .Nil): fatalError("Index out of range")
    }
  }
  public subscript(n: Int) -> Element {
   get {
      switch (n, self) {
      case (0, .Cons(let head, _)): return head
      case (_, .Cons(_, let tail)): return tail[n - 1]
      case (_, .Nil): fatalError("Index out of range")
      }
    } set {
      self = with(newValue, atIndex: n)
    }
  }
}

public enum LazyList<Element> {
  case Nil
  case Cons(head: Element, tail: () -> LazyList<Element>)
}

extension LazyList {
  public init<G : GeneratorType where G.Element == Element>(var _ gen: G) {
    self = gen.next().map {Cons(head: $0, tail: {LazyList(gen)})} ?? Nil
  }
}

extension LazyList {
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self = LazyList(seq.generate())
  }
}

extension LazyList : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    self = LazyList(arrayLiteral)
  }
}

public func lazy<T>(list: List<T>) -> LazyList<T> {
  return LazyList(list)
}

public struct LazyListGenerator<Element> : GeneratorType {
  private var list: LazyList<Element>
  public mutating func next() -> Element? {
    switch list {
    case .Nil: return nil
    case .Cons(let element, let rest):
      list = rest()
      return element
    }
  }
}

extension LazyListGenerator : LazySequenceType {
  public func generate() -> LazyListGenerator {
    return self
  }
}

extension LazyList : LazySequenceType {
  public func generate() -> LazyListGenerator<Element> {
    return LazyListGenerator(list: self)
  }
}

public func |> <T>(lhs: T, rhs: LazyList<T>) -> LazyList<T> {
  return LazyList.Cons(head: lhs, tail: {rhs})
}

public func |> <T>(lhs: T, rhs: () -> LazyList<T>) -> LazyList<T> {
  return LazyList.Cons(head: lhs, tail: rhs)
}

extension LazyList : Indexable {
  public var startIndex: Int { return 0 }
  public var endIndex: Int {
    switch self {
    case .Nil: return 0
    case .Cons(_, let tail): return tail().endIndex.successor()
    }
  }
  public func with(val: Element, atIndex n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, .Cons(_, let tail)): return val |> tail
    case (_, .Cons(let head, let tail)): return head |> {tail().with(val, atIndex: n - 1)}
    case (_, .Nil): fatalError("Index out of range")
    }
  }
  public subscript(n: Int) -> Element {
    get {
      switch (n, self) {
      case (0, .Cons(let head, _)): return head
      case (_, .Cons(_, let tail)): return tail()[n - 1]
      case (_, .Nil): fatalError("Index out of range")
      }
    } set {
      self = with(newValue, atIndex: n)
    }
  }
}
