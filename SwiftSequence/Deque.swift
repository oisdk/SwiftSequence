// MARK: Definition

public struct Deque<Element> {
  private var front, back: List<Element>
}

extension Deque : CustomDebugStringConvertible {
  public var debugDescription: String {
    return front.debugDescription + " | " + back.reverse().debugDescription
  }
}

extension Deque {
  private mutating func check() {
    switch (front, back) {
    case (.Nil, let .Cons(head, tail)) where !tail.isEmpty:
      front = tail.reverse()
      back = List<Element>.Cons(head: head, tail: .Nil)
    case (let .Cons(head, tail), .Nil) where !tail.isEmpty:
      back = tail.reverse()
      front = List<Element>.Cons(head: head, tail: .Nil)
    default:
      return
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
    return Deque(front: back, back: front)
  }
}

extension Deque {
  public var tail: Deque<Element> {
    var ret = Deque(front: front.tail, back: back)
    ret.check()
    return ret
  }
  public var initial: Deque<Element> {
    var ret = Deque(front: front, back: back.tail)
    ret.check()
    return ret
  }
}

extension Deque {
  public mutating func removeFirst() -> Element {
    defer { check() }
    return front.removeFirst()
  }
  public mutating func removeLast() -> Element {
    defer { check() }
    return back.removeFirst()
  }
}

extension Deque {
  public func map<T>(@noescape transform: Element -> T) -> Deque<T> {
    return Deque<T>(front: front.map(transform), back: back.map(transform))
  }
}

extension Deque {
  public func filter(@noescape includeElement: Element -> Bool) -> Deque<Element> {
    var ret = Deque(front: front.filter(includeElement), back: back.filter(includeElement))
    ret.check()
    return ret
  }
}

extension Deque {
  public func flatMap<T>(@noescape transform: Element -> Deque<T>) -> Deque<T> {
    var ret = Deque<T>(front: front.flatMap{List(transform($0))}, back: back.flatMap{List(transform($0))})
    ret.check()
    return ret
  }
  public func flatMap<T>(@noescape transform: Element -> T?) -> Deque<T> {
    var ret = Deque<T>(front: front.flatMap(transform), back: back.flatMap(transform))
    ret.check()
    return ret
  }
}
