public struct Deque<Element> {
  private var front, back: List<Element>
  public init() {
    (front, back)    = (.Nil, .Nil)
  }
}

extension Deque {
  private init(front: List<Element>, back: List<Element>) {
    (self.front, self.back) = (front, back)
  }
  private init(front: [Element], noReverseBack: [Element]) {
    (self.front, back) = (List(seq: front), List(seq: noReverseBack))
    check()
  }
}

extension Deque {
  private mutating func check() {
    switch (front, back) {
    case (.Nil, let .Cons(head, tail)) where !tail.isEmpty:
      (front, back) = (tail.reverse(), [head])
    case (let .Cons(head, tail), .Nil) where !tail.isEmpty:
      (back, front) = (tail.reverse(), [head])
    default:
      return
    }
  }
}

extension Deque {
  public mutating func prepend(with: Element) {
    front = with |> front
  }
  public mutating func append(with: Element) {
    back = with |> front
  }
}

public struct DequeGenerator<Element> : GeneratorType {
  private var front, back: List<Element>
  public mutating func next() -> Element? {
    switch (front, back) {
    case (let .Cons(head, tail), _):
      front = tail
      return head
    case (_, let .Cons(head, tail)):
      back = tail
      return head
    default:
      return nil
    }
  }
}

extension DequeGenerator : SequenceType {
  public func generate() -> DequeGenerator {
    return self
  }
}

extension Deque : SequenceType {
  public func generate() -> DequeGenerator<Element> {
    return DequeGenerator(front: front, back: back.reverse())
  }
}

extension Deque : CustomDebugStringConvertible {
  public var debugDescription: String {
    
    return
      ", ".join(front.map { String(reflecting: $0) }) + " | " +
      ", ".join(back.reverse().map { String(reflecting: $0) })
  }
}

extension Deque {
  public init(ar: [Element]) {
    let half = ar.endIndex / 2
    front = List(seq: ar[0..<half])
    back  = List(seq: ar[half..<ar.endIndex].reverse())
  }
}

extension Deque : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    self = Deque(ar: arrayLiteral)
  }
}

extension Deque {
  public mutating func removeLast() -> Element? {
    switch back {
    case .Nil: return nil
    case let .Cons(head, tail):
      back = tail
      return head
    }
  }
  public mutating func removeFirst() -> Element? {
    switch front {
    case .Nil: return nil
    case let .Cons(head, tail):
      front = tail
      return head
    }
  }
}

extension Deque {
  public var first: Element? {
    switch front {
    case .Nil: return nil
    case .Cons(let head, _): return head
    }
  }
  public var last: Element? {
    switch back {
    case .Nil: return nil
    case .Cons(let head, _): return head
    }
  }
}

extension Deque {
  public var tail: Deque<Element> {
    switch front {
    case .Nil: return Deque()
    case .Cons(_, let tail):
      var ret = Deque(front: tail, back: back)
      ret.check()
      return ret
    }
  }
  public var initial: Deque<Element> {
    switch back {
    case .Nil: return Deque()
    case .Cons(_, let tail):
      var ret = Deque(front: front, back: tail)
      ret.check()
      return ret
    }
  }
}

extension Deque {
  public func map<T>(@noescape transform: Element -> T) -> Deque<T> {
    return Deque<T>(
      front: front.map(transform),
      back: back.map(transform)
    )
  }
}

extension Deque {
  public func reverse() -> Deque<Element> {
    return Deque(front: back, back: front)
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
  public func flatMap<S : SequenceType>(@noescape transform: Element -> S) -> Deque<S.Generator.Element> {
    let frontAr: [S.Generator.Element] = front.flatMap(transform)
    let backAr : [S.Generator.Element] = back .flatMap(transform)
    return Deque<S.Generator.Element>(front: frontAr, noReverseBack: backAr)
  }
  public func flatMap<T>(@noescape transform: Element -> T?) -> Deque<T> {
    let frontAr: [T] = front.flatMap(transform)
    let backAr : [T] = back .flatMap(transform)
    return Deque<T>(front: frontAr, noReverseBack: backAr)
  }
}
