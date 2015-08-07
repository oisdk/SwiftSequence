/**
A [Deque](https://en.wikipedia.org/wiki/Double-ended_queue) is a data structure comprised
of two queues, with the first queue beginning at the start of the Deque, and the second
beginning at the end (in reverse):
```
First queue   Second queue
v              v
[0, 1, 2, 3] | [3, 2, 1, 0]
```
This allows for O(*1*) prepending, appending, and removal of first and last elements.

This implementation of a Deque uses two reversed `ContiguousArray`s as the queues. (this
means that the first array has reversed semantics, while the second does not) This allows
for O(*1*) indexing.
*/

public struct ContiguousDeque<Element> {
  private var front, back: ContiguousArray<Element>
  private init(_ front: ContiguousArray<Element>, _ back: ContiguousArray<Element>) {
    (self.front, self.back) = (front, back)
    check()
  }
}

extension ContiguousDeque {
  internal var isBalanced: Bool {
    return (!front.isEmpty || back.count <= 1) && (!back.isEmpty || front.count <= 1)
  }
}

extension ContiguousDeque {
  
  /**
  This is the function that maintains an invariant: If either queue has more than one
  element, the other must not be empty. This ensures that all operations can be performed
  efficiently. It is caried out whenever a mutating funciton which may break the invariant
  is performed.
  */
  
  private mutating func check() {
    if front.isEmpty && back.count > 1 {
      front.reserveCapacity(back.count - 1)
      let newBack = back.removeLast()
      front = ContiguousArray(back.reverse())
      back = [newBack]
    } else if back.isEmpty && front.count > 1 {
      back.reserveCapacity(front.count - 1)
      let newFront = front.removeLast()
      back = ContiguousArray(front.reverse())
      front = [newFront]
    }
  }
}

extension ContiguousDeque {
  public init() {
    (front, back) = ([], [])
  }
  private init(balancedF: ContiguousArray<Element>, balancedB: ContiguousArray<Element>) {
    (front, back) = (balancedF, balancedB)
  }
  public init(_ from: ContiguousDequeSlice<Element>) {
    (front, back) = (ContiguousArray(from.front), ContiguousArray(from.back))
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
  private func filter(@noescape includeElement: (Generator.Element) -> Bool) -> ContiguousArray<Element> {
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
  private func flatMap<T>(@noescape transform: (Generator.Element) -> T?) -> ContiguousArray<T> {
    var result: ContiguousArray<T> = []
    result.reserveCapacity(count)
    for element in self {
      if let transformed = transform(element) {
        result.append(transformed)
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
    var f: ContiguousArray<T> = []
    for el in front {
      let toAp = transform(el).reverse()
      f.extend(toAp)
    }
    var b: ContiguousArray<T> = []
    for el in back {
      b.extend(transform(el))
    }
    return ContiguousDeque<T>(f, b)
  }
}

extension ContiguousArray {
  private func map<T>(@noescape transform: Element -> T) -> ContiguousArray<T> {
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
  public subscript(idxs: Range<Int>) -> ContiguousDequeSlice<Element> {
    get {
      switch (idxs.startIndex < front.endIndex, idxs.endIndex <= front.endIndex) {
      case (true, true):
        let start = front.endIndex - idxs.endIndex
        let end   = front.endIndex - idxs.startIndex
        return ContiguousDequeSlice( front[start.successor()..<end], [front[start]] )
      case (true, false):
        let frontTo = front.endIndex - idxs.startIndex
        let backTo  = idxs.endIndex - front.endIndex
        return ContiguousDequeSlice( front[0 ..< frontTo], back [0 ..< backTo])
      case (false, false):
        let start = idxs.startIndex - front.endIndex
        let end   = idxs.endIndex - front.endIndex
        return ContiguousDequeSlice( [back[start]], back[start.successor() ..< end] )
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
    check()
  }
  public mutating func prepend(with: Element) {
    front.append(with)
    check()
  }
  public mutating func extend<S : SequenceType where S.Generator.Element == Element>(with: S) {
    back.extend(with)
    check()
  }
  public mutating func prextend<S : SequenceType where S.Generator.Element == Element>(with: S) {
    front.extend(with.reverse())
    check()
  }
}

extension ContiguousDeque {
  public mutating func insert(newElement: Element, atIndex i: Int) {
    i < front.endIndex ?
      front.insert(newElement, atIndex: front.endIndex - i) :
      back .insert(newElement, atIndex: i - front.endIndex)
    check()
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
    defer { check() }
    return i < front.endIndex ?
      front.removeAtIndex(front.endIndex.predecessor() - i) :
      back .removeAtIndex(i - front.endIndex)
  }
}

extension ContiguousDeque {
  public mutating func removeLast() -> Element {
    if back.isEmpty { return front.removeLast() }
    defer { check() }
    return back.removeLast()
  }
  public mutating func removeFirst() -> Element {
    if front.isEmpty { return back.removeLast() }
    defer { check() }
    return front.removeLast()
  }
}

extension ContiguousDeque {
  public func dropFirst() -> ContiguousDequeSlice<Element> {
    return ContiguousDequeSlice(front.dropLast(), ArraySlice(back))
  }
  public func dropLast() -> ContiguousDequeSlice<Element> {
    return ContiguousDequeSlice(ArraySlice(front), back.dropLast())
  }
}

extension ContiguousDeque {
  mutating public func reserveCapacity(n: Int) {
    let half = n / 2
    front.reserveCapacity(half)
    back.reserveCapacity(n - half)
  }
}

public struct ContiguousDequeSlice<Element> {
  private var front, back: ArraySlice<Element>
  private init(_ front: ArraySlice<Element>, _ back: ArraySlice<Element>) {
    (self.front, self.back) = (front, back)
    check()
  }
}

extension ContiguousDequeSlice {
  private mutating func check() {
    if front.isEmpty && back.count > 1 {
      let newBack = back.removeLast()
      front = ArraySlice(back.reverse())
      back = [newBack]
    } else if back.isEmpty && front.count > 1 {
      let newFront = front.removeLast()
      back = ArraySlice(front.reverse())
      front = [newFront]
    }
  }
}

extension ContiguousDequeSlice {
  internal var isBalanced: Bool {
    return (!front.isEmpty || back.count <= 1) && (!back.isEmpty || front.count <= 1)
  }
}

extension ContiguousDequeSlice {
  public init() {
    (front, back) = ([], [])
  }
  private init(balancedF: ArraySlice<Element>, balancedB: ArraySlice<Element>) {
    (front, back) = (balancedF, balancedB)
  }
}

public struct ContiguousDequeSliceGenerator<Element> : GeneratorType, SequenceType {
  private var fGen: IndexingGenerator<ReverseRandomAccessCollection<ArraySlice<Element>>>?
  private var sGen: IndexingGenerator<ArraySlice<Element>>
  mutating public func next() -> Element? {
    if fGen == nil { return sGen.next() }
    return fGen!.next() ?? {
      fGen = nil
      return sGen.next()
      }()
  }
  public func generate() -> ContiguousDequeSliceGenerator {
    return self
  }
}

extension ContiguousDequeSlice : SequenceType {
  public func generate() -> ContiguousDequeSliceGenerator<Element> {
    return ContiguousDequeSliceGenerator(fGen: front.reverse().generate(), sGen: back.generate())
  }
}

extension ContiguousDequeSlice : Indexable {
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

extension ContiguousDequeSlice {
  private init(array: [Element]) {
    let half = array.endIndex / 2
    self.init(
      balancedF: ArraySlice(array[0..<half].reverse()),
      balancedB: ArraySlice(array[half..<array.endIndex])
    )
  }
}

extension ContiguousDequeSlice : ArrayLiteralConvertible {
  public init<S : SequenceType where S.Generator.Element == Element>(_ seq: S) {
    self.init(array: Array(seq))
  }
  public init(arrayLiteral: Element...) {
    self.init(array: arrayLiteral)
  }
}

extension ContiguousDequeSlice : CustomDebugStringConvertible {
  public var debugDescription: String {
    return
      "[" +
        ", ".join(front.reverse().map { String(reflecting: $0) }) +
        " | " +
        ", ".join(back.map { String(reflecting: $0) }) + "]"
  }
}

extension ArraySlice {
  public func filter(@noescape includeElement: (Generator.Element) -> Bool) -> ArraySlice<Element> {
    var result: ArraySlice = []
    result.reserveCapacity(count)
    for element in self where includeElement(element) { result.append(element) }
    return result
  }
}

extension ContiguousDequeSlice {
  public func filter(@noescape includeElement: Element -> Bool) -> ContiguousDequeSlice<Element> {
    return ContiguousDequeSlice(
      front.filter(includeElement),
      back .filter(includeElement)
    )
  }
}

extension ArraySlice {
  public func flatMap<T>(@noescape transform: (Generator.Element) -> T?) -> ArraySlice<T> {
    var result: ArraySlice<T> = []
    result.reserveCapacity(count)
    for element in self {
      if let transformed = transform(element) {
        result.append(transformed)
      }
    }
    return result
  }
}

extension ContiguousDequeSlice {
  public func flatMap<T>(@noescape transform: Element -> T?) -> ContiguousDequeSlice<T> {
    return ContiguousDequeSlice<T>(
      front.flatMap(transform),
      back .flatMap(transform)
    )
  }
  public func flatMap<T>(@noescape transform: Element -> ContiguousDequeSlice<T>) -> ContiguousDequeSlice<T> {
    var f: ArraySlice<T> = []
    for el in front {
      let toAp = transform(el).reverse()
      f.extend(toAp)
    }
    var b: ArraySlice<T> = []
    for el in back {
      b.extend(transform(el))
    }
    return ContiguousDequeSlice<T>(f, b)
  }
}

extension ArraySlice {
  public func map<T>(@noescape transform: Element -> T) -> ArraySlice<T> {
    var result: ArraySlice<T> = []
    result.reserveCapacity(count)
    for element in self { result.append(transform(element)) }
    return result
  }
}

extension ContiguousDequeSlice {
  public func map<T>(@noescape transform: Element -> T) -> ContiguousDequeSlice<T> {
    return ContiguousDequeSlice<T>(
      balancedF: front.map(transform),
      balancedB: back .map(transform)
    )
  }
}

extension ContiguousDequeSlice {
  public func reverse() -> ContiguousDequeSlice<Element> {
    return ContiguousDequeSlice(
      balancedF: back,
      balancedB: front
    )
  }
}

extension ContiguousDequeSlice {
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

extension ContiguousDequeSlice {
  public subscript(idxs: Range<Int>) -> ContiguousDequeSlice<Element> {
    get {
      switch (idxs.startIndex < front.endIndex, idxs.endIndex <= front.endIndex) {
      case (true, true):
        let start = front.endIndex - idxs.endIndex
        let end   = front.endIndex - idxs.startIndex
        return ContiguousDequeSlice( front[start.successor()..<end], [front[start]] )
      case (true, false):
        let frontTo = front.endIndex - idxs.startIndex
        let backTo  = idxs.endIndex - front.endIndex
        return ContiguousDequeSlice( front[0 ..< frontTo], back [0 ..< backTo])
      case (false, false):
        let start = idxs.startIndex - front.endIndex
        let end   = idxs.endIndex - front.endIndex
        return ContiguousDequeSlice( [back[start]], back[start.successor() ..< end] )
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

extension ContiguousDequeSlice {
  public mutating func append(with: Element) {
    back.append(with)
    check()
  }
  public mutating func prepend(with: Element) {
    front.append(with)
    check()
  }
  public mutating func extend<S : SequenceType where S.Generator.Element == Element>(with: S) {
    back.extend(with)
    check()
  }
  public mutating func prextend<S : SequenceType where S.Generator.Element == Element>(with: S) {
    front.extend(with.reverse())
    check()
  }
}

extension ContiguousDequeSlice {
  public mutating func insert(newElement: Element, atIndex i: Int) {
    i < front.endIndex ?
      front.insert(newElement, atIndex: front.endIndex - i) :
      back .insert(newElement, atIndex: i - front.endIndex)
    check()
  }
}

extension ContiguousDequeSlice {
  public mutating func removeAll(keepCapacity: Bool = false) {
    front.removeAll(keepCapacity: keepCapacity)
    back .removeAll(keepCapacity: keepCapacity)
  }
}

extension ContiguousDequeSlice {
  public mutating func removeAtIndex(i: Int) -> Element {
    defer { check() }
    return i < front.endIndex ?
      front.removeAtIndex(front.endIndex.predecessor() - i) :
      back .removeAtIndex(i - front.endIndex)
  }
}

extension ContiguousDequeSlice {
  public mutating func removeLast() -> Element {
    guard !back.isEmpty else { return front.removeLast() }
    defer { check() }
    return back.removeLast()
  }
  public mutating func removeFirst() -> Element {
    guard !front.isEmpty else { return back.removeLast() }
    defer { check() }
    return front.removeLast()
  }
}

extension ContiguousDequeSlice {
  public func dropFirst() -> ContiguousDequeSlice {
    return ContiguousDequeSlice(front.dropLast(), back)
  }
  
  public func dropLast() -> ContiguousDequeSlice {
    return ContiguousDequeSlice(front, back.dropLast())
  }
}

extension ContiguousDequeSlice {
  mutating public func reserveCapacity(n: Int) {
    let half = n / 2
    front.reserveCapacity(half)
    back.reserveCapacity(n - half)
  }
}