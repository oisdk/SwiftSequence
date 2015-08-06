// MARK: Definition

public struct Deque<Element> {
  private var front: List<Element> { didSet { check() } }
  private var back : List<Element> { didSet { check() } }
  private init(_ front: List<Element>, _ back: List<Element>) {
    (self.front, self.back) = (front, back)
    check()
  }
}

extension Deque {
  private init(balancedFront: List<Element>, balancedBack: List<Element>) {
    (front, back) = (balancedFront, balancedBack)
  }
}

extension Deque : CustomDebugStringConvertible {
  public var debugDescription: String {
    return
      ", ".join(front.map{String(reflecting: $0)}) +
      " | " +
      ", ".join(back.reverse().map{String(reflecting: $0)})
  }
}

extension Deque {
  private mutating func check() {
    switch (front, back) {
    case (.Nil, let .Cons(head, tail)) where !tail.isEmpty:
      (front, back) = (tail.reverse(), [head])
    case (let .Cons(head, tail), .Nil) where !tail.isEmpty:
      (back, front) = (tail.reverse(), [head])
    default: return
    }
  }
}

extension Deque {
  internal var isBalanced: Bool {
    switch (front, back) {
    case (.Nil, let .Cons(_, tail)) where !tail.isEmpty: return false
    case (let .Cons(_, tail), .Nil) where !tail.isEmpty: return false
    default: return true
    }
  }
}

// MARK: Init

extension Deque {
  public init(array: [Element]) {
    let half = array.endIndex / 2
    front = List(array[0..<half])
    back = List(array[half..<array.endIndex].reverse())
  }
}

extension Deque : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    self.init(array: arrayLiteral)
  }
}

extension Deque {
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self.init(array: Array(seq))
  }
}

// MARK: SequenceType

public struct DequeGenerator<Element> : GeneratorType, SequenceType {
  private var front, back: List<Element>
  public mutating func next() -> Element? {
    switch (front, back) {
    case (let .Cons(head, tail), _):
      front = tail
      return head
    case (_, let .Cons(head, tail)):
      back = tail
      return head
    default: return nil
    }
  }
  public func generate() -> DequeGenerator {
    return self
  }
}

extension Deque : SequenceType {
  public func generate() -> DequeGenerator<Element> {
    return DequeGenerator(front: front, back: back.reverse())
  }
}

// MARK: More effecient implementations

extension Deque {
  public var first: Element? {
    return front.first
  }
  public var last: Element? {
    return back.first
  }
}

extension Deque {
  public func reverse() -> Deque<Element> {
    return Deque(balancedFront: back, balancedBack: front)
  }
}

extension Deque {
  public var tail: Deque<Element> {
    return Deque(front.tail, back)
  }
  public var initial: Deque<Element> {
    return Deque(front, back.tail)
  }
}

public func dropFirst<T>(deque: Deque<T>) -> Deque<T> {
  return deque.tail
}

public func dropLast<T>(deque: Deque<T>) -> Deque<T> {
  return deque.initial
}

extension Deque {
  public mutating func removeFirst() -> Element {
    return front.removeFirst()
  }
  public mutating func removeLast() -> Element {
    return back.removeFirst()
  }
}

extension Deque {
  public func map<T>(@noescape transform: Element -> T) -> Deque<T> {
    return Deque<T>(
      balancedFront: front.map(transform),
      balancedBack : back .map(transform)
    )
  }
}

extension Deque {
  public func filter(@noescape includeElement: Element -> Bool) -> Deque<Element> {
    return Deque(front.filter(includeElement), back .filter(includeElement))
  }
}

extension Deque {
  public func flatMap<T>(@noescape transform: Element -> Deque<T>) -> Deque<T> {
    return Deque<T>(
      front.flatMap{List(transform($0))},
      back .flatMap{List(transform($0).reverse())}
    )
  }
  
  public func flatMap<T>(@noescape transform: Element -> T?) -> Deque<T> {
    return Deque<T>(front.flatMap(transform), back.flatMap(transform))
  }
}
