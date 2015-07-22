public enum LazyList<Element> {
  case Nil
  case Cons(head: Element, tail: () -> LazyList<Element>)
}

public extension Optional {
  public func flatMap<U>(@noescape transform: T -> LazyList<U>) -> LazyList<U> {
    return map(transform) ?? nil
  }
}

public func |> <T>(lhs: T, rhs: () -> LazyList<T>) -> LazyList<T> {
  return LazyList.Cons(head: lhs, tail: rhs)
}

public func |> <T>(lhs: T, @autoclosure(escaping) rhs: () -> LazyList<T>) -> LazyList<T> {
  return LazyList.Cons(head: lhs, tail: rhs)
}

public prefix func |> <T>(rhs: () -> LazyList<T>)(lhs: T) -> LazyList<T> {
  return LazyList.Cons(head: lhs, tail: rhs)
}

public prefix func |> <T>(@autoclosure(escaping) rhs: () -> LazyList<T>)(lhs: T) -> LazyList<T> {
  return LazyList.Cons(head: lhs, tail: rhs)
}

public extension LazyList {
  public init<G : GeneratorType where G.Element == Element>(var _ gen: G) {
    self = gen.next().flatMap(|>LazyList(gen))
  }
}

public extension LazyList {
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self = LazyList(seq.generate())
  }
}

extension LazyList : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    self = LazyList(arrayLiteral)
  }
}

extension LazyList : NilLiteralConvertible {
  public init(nilLiteral: ()) {
    self = .Nil
  }
}

public func lazy<T>(list: List<T>) -> LazyList<T> {
  return LazyList(list)
}

public struct LazyListGenerator<Element> : GeneratorType {
  private var list: () -> LazyList<Element>
  public mutating func next() -> Element? {
    switch list() {
    case .Nil: return nil
    case let .Cons(head, tail):
      list = tail
      return head
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
    return LazyListGenerator(list: {self})
  }
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
    case (_, let .Cons(head, tail)): return head |> tail().with(val, atIndex: n - 1)
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

extension LazyList {
  public var isEmpty: Bool {
    switch self {
    case .Nil:  return true
    case .Cons: return false
    }
  }
}

public extension LazyList {
  public func appended(with: Element) -> LazyList<Element> {
    switch self {
    case .Nil: return with |> nil
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
    S : SequenceType where S.Generator.Element == Element
    >(with: S) -> LazyList<Element> {
      return extended(LazyList(with))
  }
}