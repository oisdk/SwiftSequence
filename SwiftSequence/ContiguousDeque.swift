public struct ContiguousDeque<Element> {
  private var front: ContiguousArray<Element> { didSet { check() } }
  private var back : ContiguousArray<Element> { didSet { check() } }
  private init(_ front: ContiguousArray<Element>, _ back: ContiguousArray<Element>) {
    (self.front, self.back) = (front, back)
    check()
  }
}

extension ContiguousDeque {
  public init() {
    (front, back) = ([], [])
  }
  private init(balancedF: ContiguousArray<Element>, balancedB: ContiguousArray<Element>) {
    (front, back) = (balancedF, balancedB)
  }
}

extension ContiguousDeque {
  private mutating func check() {
    if front.isEmpty && back.count > 1 {
      front = ContiguousArray(dropFirst(back).reverse())
      back = [back[0]]
    } else if back.isEmpty && front.count > 1 {
      back = ContiguousArray(dropFirst(front).reverse())
      front = [front[0]]
    }
  }
}

public struct ContiguousDequeGenerator<Element> : GeneratorType, SequenceType {
  private var fGen: IndexingGenerator<ReverseRandomAccessCollection<ContiguousArray<Element>>>?
  private var sGen: IndexingGenerator<ContiguousArray<Element>>
  mutating public func next() -> Element? {
    if fGen == nil { return sGen.next() }
    return fGen!.next() ?? {
      fGen = nil
      return sGen.next()
      }()
  }
  public func generate() -> ContiguousDequeGenerator {
    return self
  }
}

extension ContiguousDeque : SequenceType {
  public func generate() -> ContiguousDequeGenerator<Element> {
    return ContiguousDequeGenerator(fGen: front.reverse().generate(), sGen: back.generate())
  }
}

extension ContiguousDeque : Indexable {
  public var startIndex: Int { return 0 }
  public var endIndex: Int { return front.endIndex + back.endIndex }
  public var count: Int { return endIndex }
  public subscript(idx: Int) -> Element {
    get {
      return idx < front.endIndex ?
        front[front.endIndex.predecessor() - idx] :
        back[idx - front.endIndex]
    } set {
      idx < front.endIndex ?
        (front[front.endIndex.predecessor() - idx] = newValue) :
        (back[idx - front.endIndex] = newValue)
    }
  }
}

extension ContiguousDeque {
  private init(array: [Element]) {
    let half = array.endIndex / 2
    self.init(
      balancedF: ContiguousArray(array[0..<half].reverse()),
      balancedB: ContiguousArray(array[half..<array.endIndex])
    )
  }
}

extension ContiguousDeque : ArrayLiteralConvertible {
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self.init(array: Array(seq))
  }
  public init(arrayLiteral: Element...) {
    self.init(array: arrayLiteral)
  }
}

extension ContiguousDeque : CustomDebugStringConvertible {
  public var debugDescription: String {
    return
      "[" +
        ", ".join(front.reverse().map { String(reflecting: $0) }) +
        " | " +
        ", ".join(back.map { String(reflecting: $0) }) + "]"
  }
}

extension ContiguousArray {
  public func filter(@noescape includeElement: (Generator.Element) -> Bool) -> ContiguousArray<Element> {
    var result: ContiguousArray = []
    result.reserveCapacity(count)
    for element in self where includeElement(element) { result.append(element) }
    return result
  }
}

extension ContiguousDeque {
  public func filter(@noescape includeElement: Element -> Bool) -> ContiguousDeque<Element> {
    return ContiguousDeque(
      front.filter(includeElement),
      back .filter(includeElement)
    )
  }
}

extension ContiguousArray {
  public func flatMap<T>(@noescape transform: (Generator.Element) -> T?) -> ContiguousArray<T> {
    var result: ContiguousArray<T> = []
    result.reserveCapacity(count)
    for element in self {
      if let tansformed = transform(element) {
        result.append(tansformed)
      }
    }
    return result
  }
}

extension ContiguousDeque {
  public func flatMap<T>(@noescape transform: Element -> T?) -> ContiguousDeque<T> {
    return ContiguousDeque<T>(
      front.flatMap(transform),
      back .flatMap(transform)
    )
  }
  public func flatMap<T>(@noescape transform: Element -> ContiguousDeque<T>) -> ContiguousDeque<T> {
    return ContiguousDeque<T>(
      ContiguousArray(front.flatMap{transform($0).reverse()}),
      ContiguousArray(back .flatMap{transform($0)})
    )
  }
}

extension ContiguousArray {
  public func map<T>(@noescape transform: Element -> T) -> ContiguousArray<T> {
    var result: ContiguousArray<T> = []
    result.reserveCapacity(count)
    for element in self { result.append(transform(element)) }
    return result
  }
}

extension ContiguousDeque {
  public func map<T>(@noescape transform: Element -> T) -> ContiguousDeque<T> {
    return ContiguousDeque<T>(
      balancedF: front.map(transform),
      balancedB: back .map(transform)
    )
  }
}

extension ContiguousDeque {
  public func reverse() -> ContiguousDeque<Element> {
    return ContiguousDeque(
      balancedF: back,
      balancedB: front
    )
  }
}

extension ContiguousDeque {
  public var first: Element? {
    return front.last
  }
  public var last: Element? {
    return back.last
  }
  public var isEmpty: Bool {
    return front.isEmpty && back.isEmpty
  }
}

extension ContiguousDeque {
  public subscript(idxs: Range<Int>) -> ContiguousArray<Element> {
    get {
      switch (idxs.startIndex < front.endIndex, idxs.endIndex < front.endIndex) {
      case (true, true):
        return ContiguousArray(front[
          (front.endIndex - idxs.endIndex) ..<
            (front.endIndex - idxs.startIndex)
          ].reverse())
      case (true, false):
        return ContiguousArray(
          front[0 ..< (front.endIndex - idxs.startIndex)].reverse() +
            back [0 ..< (idxs.endIndex - front.endIndex)]
        )
      case (false, false):
        return ContiguousArray(
          back[(idxs.startIndex - front.endIndex)..<(idxs.endIndex - front.endIndex)]
        )
      default:
        fatalError()
      }
    } set {
      for (index, value) in zip(idxs, newValue) {
        self[index] = value
      }
    }
  }
}

extension ContiguousDeque {
  public mutating func append(with: Element) {
    back.append(with)
  }
  public mutating func prepend(with: Element) {
    front.append(with)
  }
  public mutating func extend<S : SequenceType where S.Generator.Element == Element>(with: S) {
    back.extend(with)
  }
  public mutating func prextend<S : SequenceType where S.Generator.Element == Element>(with: S) {
    front.extend(with.reverse())
  }
}

extension ContiguousDeque {
  public mutating func insert(newElement: Element, atIndex i: Int) {
    i < front.endIndex ?
      front.insert(newElement, atIndex: front.endIndex - i) :
      back .insert(newElement, atIndex: i - front.endIndex)
  }
}

extension ContiguousDeque {
  public mutating func removeAll(keepCapacity: Bool = false) {
    front.removeAll(keepCapacity: keepCapacity)
    back .removeAll(keepCapacity: keepCapacity)
  }
}

extension ContiguousDeque {
  public mutating func removeAtIndex(i: Int) -> Element {
    return i < front.endIndex ?
      front.removeAtIndex(front.endIndex - i) :
      back .removeAtIndex(i - front.endIndex)
  }
}

extension ContiguousDeque {
  public mutating func removeLast() -> Element {
    return back.removeLast()
  }
  public mutating func removeFirst() -> Element {
    return front.removeLast()
  }
}

public func dropFirst<T>(var from: ContiguousDeque<T>) -> ContiguousDeque<T> {
  let _ = from.removeFirst()
  return from
}

public func dropLast<T>(var from: ContiguousDeque<T>) -> ContiguousDeque<T> {
  let _ = from.removeLast()
  return from
}

extension ContiguousDeque {
  mutating public func replaceRange<
    C : CollectionType where C.Generator.Element == Element
    >(subRange: Range<Int>, with newElements: C) {
    switch (subRange.startIndex < front.endIndex, subRange.endIndex < front.endIndex) {
    case (true, true):
      front.replaceRange(
        (front.endIndex - subRange.endIndex) ..<
          (front.endIndex - subRange.startIndex),
        with: newElements.reverse()
      )
    case (true, false):
      front.replaceRange(0 ..< (front.endIndex - subRange.startIndex), with: [])
      back.replaceRange(0 ..< (subRange.endIndex - front.endIndex), with: newElements)
    case (false, false):
      back.replaceRange(
        (subRange.startIndex - front.endIndex) ..<
          (subRange.endIndex - front.endIndex),
        with: newElements
      )
    default:
      fatalError()
    }
  }
}

extension ContiguousDeque {
  mutating public func reserveCapacity(n: Int) {
    let half = n / 2
    front.reserveCapacity(half)
    back.reserveCapacity(n - half)
  }
}