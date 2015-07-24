public enum LazyList<Element> {
  case Nil
  case Cons(head: Element, tail: () -> LazyList<Element>)
}

public extension Optional {
  public func flatMap<U>(@noescape transform: T -> LazyList<U>) -> LazyList<U> {
    return map(transform) ?? .Nil
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

extension LazyList : CustomDebugStringConvertible {
  public var debugDescription: String {
    return ", ".join(map{String(reflecting: $0)})
  }
}

extension LazyList {
  public var startIndex: Int { return 0 }
  
  /// BEWARE: O(N)
  
  public var count: Int {
    switch self {
    case .Nil: return 0
    case .Cons(_, let tail): return tail().count.successor()
    }
  }

  /// BEWARE: O(N)
  
  public subscript(n: Int) -> Element {
    switch (n, self) {
    case (0, .Cons(let head, _)): return head
    case (_, .Cons(_, let tail)): return tail()[n - 1]
    case (_, .Nil): fatalError("Index out of range")
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
  public func replacedWith(val: Element, atIndex n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, .Cons(_, let tail)): return val |> tail
    case (_, let .Cons(head, tail)): return head |> tail().replacedWith(val, atIndex: n - 1)
    case (_, .Nil): fatalError("Index out of range")
    }
  }
  public func inserted(val: Element, atIndex n: Int) -> LazyList<Element> {
    switch (n, self) {
    case (0, _): return val |> self
    case (_, let .Cons(head, tail)): return head |> tail().replacedWith(val, atIndex: n - 1)
    case (_, .Nil): fatalError("Index out of range")
    }
  }
}

extension LazyList {
  func filter(includeElement: Element -> Bool) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      return includeElement(head) ?
        head |> tail().filter(includeElement) :
        tail().filter(includeElement)
    }
  }
}
public extension LazyList {
  public func prepended(with: Element) -> LazyList<Element> {
    return with |> self
  }
  public func appended(@autoclosure(escaping) with: () -> Element) -> LazyList<Element> {
    switch self {
    case .Nil: return with() |> .Nil
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
  private func prextended<
    G : GeneratorType where
    G.Element == Element
    >(var with: G) -> LazyList<Element> {
      return with.next().map(|>self.prextended(with)) ?? self
  }
  public func prextended<
    S : SequenceType where
    S.Generator.Element == Element
    >(seq: S) -> LazyList<Element> {
      return prextended(seq.generate())
  }
  public func prextended(with: LazyList<Element>) -> LazyList<Element> {
    return with.extended(self)
  }
}

public func + <T>(lhs: LazyList<T>, rhs: LazyList<T>) -> LazyList<T> {
  return lhs.extended(rhs)
}