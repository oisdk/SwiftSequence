public enum List<Element> {
  case Nil
  indirect case Cons(head: Element, tail: List<Element>)
}

infix operator |> {
  associativity right
  precedence 90
}

public func |> <T>(lhs: T, rhs: List<T>) -> List<T> {
  return .Cons(head: lhs, tail: rhs)
}

prefix operator |> {}

public prefix func |> <T>(rhs: List<T>)(lhs: T) -> List<T> {
  return lhs |> rhs
}

public struct ListGenerator<Element> : GeneratorType {
  private var list: List<Element>
  public mutating func next() -> Element? {
    switch list {
    case .Nil: return nil
    case let .Cons(head, tail):
      list = tail
      return head
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

public extension Optional {
  public func flatMap<U>(@noescape transform: T -> List<U>) -> List<U> {
    return map(transform) ?? .Nil
  }
}

public extension List {
  public init<G : GeneratorType where G.Element == Element>(var _ gen: G) {
    self = gen.next().flatMap(|>List(gen))
  }
  public init<S : SequenceType where S.Generator.Element == Element>(seq: S) {
    self = List(seq.generate())
  }
}

extension List : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    self = List(arrayLiteral.generate())
  }
}

public extension List {
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
    case (_, let .Cons(head, tail)): return head |> tail.with(val, atIndex: n - 1)
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
