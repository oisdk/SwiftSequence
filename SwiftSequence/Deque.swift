public struct Deque<Element> {
  private var front: List<Element> { didSet { check() } }
  private var back : List<Element> { didSet { check() } }
  private var fCount, bCount: Int
  
  public init() {
    front = .Nil
    back  = .Nil
    fCount = 0
    bCount = 0
  }
}

extension Deque {
  private init(front: List<Element>, back: List<Element>, fCount: Int, bCount: Int) {
    self.front = front
    self.back  = back
    self.fCount = fCount
    self.bCount = bCount
  }
  private init(front: [Element], noReverseBack: [Element]) {
    self.front = List(seq: front)
    self.back = List(seq: noReverseBack)
    fCount = front.count
    bCount = noReverseBack.count
    check()
  }
}

extension Deque {
  private mutating func check() {
    if fCount == 1 || bCount == 1 { return }
    switch (front, back) {
    case (.Nil, let .Cons(head, tail)):
      front = tail.reverse()
      back = [head]
      (fCount, bCount) = (bCount - 1, 1)
    case (let .Cons(head, tail), .Nil):
      back = tail.reverse()
      front = [head]
      (bCount, fCount) = (fCount - 1, 1)
    default:
      return
    }
  }
}

extension Deque {
  public mutating func cons(with: Element) {
    ++fCount
    front = with |> front
  }
  public mutating func snoc(with: Element) {
    ++bCount
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
    
    return "[\(fCount), \(bCount)]: " +
      ", ".join(front.map { String(reflecting: $0) }) + " | " +
      ", ".join(back.reverse().map { String(reflecting: $0) })
  }
}

extension Deque {
  public init(ar: [Element]) {
    fCount = ar.endIndex / 2
    front = List(seq: ar[0..<fCount])
    bCount = ar.endIndex - fCount
    back  = List(seq: ar[fCount..<ar.endIndex].reverse())
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
      --bCount
      back = tail
      return head
    }
  }
  public mutating func removeFirst() -> Element? {
    switch front {
    case .Nil: return nil
    case let .Cons(head, tail):
      --fCount
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
      var ret = Deque(front: tail, back: back, fCount: fCount - 1, bCount: bCount)
      ret.check()
      return ret
    }
  }
  public var initial: Deque<Element> {
    switch back {
    case .Nil: return Deque()
    case .Cons(_, let tail):
      var ret = Deque(front: front, back: tail, fCount: fCount, bCount: bCount - 1)
      ret.check()
      return ret
    }
  }
}

extension Deque : Indexable {
  public var startIndex: Int { return 0 }
  public var count     : Int { return fCount + bCount }
  public var endIndex  : Int { return count }
  public subscript(n: Int) -> Element {
    get { return n < fCount ? front[n] : back[bCount - (n - fCount) - 1] }
    set(v) { n < fCount ? (front[n] = v) : (back[bCount - (n - fCount) - 1] = v) }
  }
}

extension Deque {
  public func map<T>(@noescape transform: Element -> T) -> Deque<T> {
    return Deque<T>(
      front: front.map(transform),
      back: back.map(transform),
      fCount: fCount, bCount: bCount
    )
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
