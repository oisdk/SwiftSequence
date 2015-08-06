public struct ContiguousList<Element> {
  private var contents: ContiguousArray<Element>
}

public struct ContiguousListIndex {
  private let val: Int
}

extension ContiguousListIndex : Equatable, ForwardIndexType {
  public func successor() -> ContiguousListIndex {
    return ContiguousListIndex(val: val.predecessor())
  }
}

public func == (lhs: ContiguousListIndex, rhs: ContiguousListIndex) -> Bool {
  return lhs.val == rhs.val
}
public func < (lhs: ContiguousListIndex, rhs: ContiguousListIndex) -> Bool {
  return lhs.val > rhs.val
}
public func > (lhs: ContiguousListIndex, rhs: ContiguousListIndex) -> Bool {
  return lhs.val < rhs.val
}

extension ContiguousListIndex : BidirectionalIndexType {
  public func predecessor() -> ContiguousListIndex {
    return ContiguousListIndex(val: val.successor())
  }
}

extension ContiguousListIndex : RandomAccessIndexType {
  public func distanceTo(other: ContiguousListIndex) -> Int {
    return val - other.val
  }
  public func advancedBy(n: Int) -> ContiguousListIndex {
    return ContiguousListIndex(val: val - n)
  }
}

extension ContiguousList : Indexable {
  public var endIndex: ContiguousListIndex {
    return ContiguousListIndex(val: contents.startIndex.predecessor())
  }
  public var startIndex: ContiguousListIndex {
    return ContiguousListIndex(val: contents.endIndex.predecessor())
  }
  public var count: Int {
    return contents.count
  }
  public subscript(idx: ContiguousListIndex) -> Element {
    get { return contents[idx.val] }
    set { contents[idx.val] = newValue }
  }
}

extension ContiguousList : SequenceType {
  public func generate() -> IndexingGenerator<ContiguousList> {
    return IndexingGenerator(self)
  }
}

extension ContiguousList : CustomDebugStringConvertible {
  public var debugDescription: String {
    return "[" + ", ".join(map {String(reflecting: $0)}) + "]"
  }
}

extension ContiguousList : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    contents = ContiguousArray(arrayLiteral.reverse())
  }
}

extension ContiguousList {
  public mutating func removeFirst() -> Element {
    return contents.removeLast()
  }
  public var first: Element? {
    return contents.last
  }
  public var last: Element? {
    return contents.first
  }
  public var isEmpty: Bool {
    return contents.isEmpty
  }
}

public struct ContiguousListSlice<Element> {
  private var contents: ArraySlice<Element>
}

extension ContiguousListSlice : Indexable {
  public var endIndex: ContiguousListIndex {
    return ContiguousListIndex(val: contents.startIndex.predecessor())
  }
  public var startIndex: ContiguousListIndex {
    return ContiguousListIndex(val: contents.endIndex.predecessor())
  }
  public var count: Int {
    return contents.count
  }
  public subscript(idx: ContiguousListIndex) -> Element {
    get { return contents[idx.val] }
    set { contents[idx.val] = newValue }
  }
}

extension ContiguousListSlice : SequenceType {
  public func generate() -> IndexingGenerator<ContiguousListSlice> {
    return IndexingGenerator(self)
  }
}

extension ContiguousListSlice : CustomDebugStringConvertible {
  public var debugDescription: String {
    return "[" + ", ".join(map {String(reflecting: $0)}) + "]"
  }
}

extension ContiguousListSlice : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    contents = ArraySlice(arrayLiteral.reverse())
  }
}

extension ContiguousListSlice {
  mutating func removeFirst() -> Element {
    return contents.removeLast()
  }
  public var first: Element? {
    return contents.last
  }
  var last: Element? {
    return contents.first
  }
  public var isEmpty: Bool {
    return contents.isEmpty
  }
}

extension ContiguousList {
  public subscript(idxs: Range<ContiguousListIndex>) -> ContiguousListSlice<Element> {
    get {
      let start = idxs.endIndex.val.successor()
      let end   = idxs.startIndex.val.successor()
      return ContiguousListSlice(contents: contents[start..<end])
    } set {
      let start = idxs.endIndex.val.successor()
      let end   = idxs.startIndex.val.successor()
      contents[start..<end] = newValue.contents
    }
  }
}

extension ContiguousListSlice {
  public subscript(idxs: Range<ContiguousListIndex>) -> ContiguousListSlice<Element> {
    get {
      let start = idxs.endIndex.val.successor()
      let end   = idxs.startIndex.val.successor()
      return ContiguousListSlice(contents: contents[start..<end] )
    } set {
      let start = idxs.endIndex.val.successor()
      let end   = idxs.startIndex.val.successor()
      contents[start..<end] = newValue.contents
    }
  }
}

extension ContiguousList {
  public init() {
    contents = []
  }
}

extension ContiguousListSlice {
  public init() {
    contents = []
  }
}

extension ContiguousList {
  init<S : SequenceType where S.Generator.Element == Element>(seq: S) {
    contents = ContiguousArray(seq.reverse())
  }
}

extension ContiguousListSlice {
  init<S : SequenceType where S.Generator.Element == Element>(seq: S) {
    contents = ArraySlice(seq.reverse())
  }
}

extension ContiguousList {
  public mutating func prepend(with: Element) {
    contents.append(with)
  }
}

extension ContiguousListSlice {
  public mutating func prepend(with: Element) {
    contents.append(with)
  }
}

extension ContiguousList {
  mutating public func reserveCapacity(n: Int) {
    contents.reserveCapacity(n)
  }
}

extension ContiguousListSlice {
  mutating public func reserveCapacity(n: Int) {
    contents.reserveCapacity(n)
  }
}

extension ContiguousList {
  public subscript(idx: Int) -> Element {
    get { return contents[contents.endIndex.predecessor() - idx] }
    set { contents[contents.endIndex.predecessor() - idx] = newValue }
  }
}

extension ContiguousList {
  public subscript(idxs: Range<Int>) -> ContiguousListSlice<Element> {
    get {
      let str = contents.endIndex - idxs.endIndex
      let end = contents.endIndex - idxs.startIndex
      return ContiguousListSlice(contents: contents[str..<end] )
    } set {
      let str = contents.endIndex - idxs.endIndex
      let end = contents.endIndex - idxs.startIndex
      contents[str..<end] = newValue.contents
    }
  }
}

extension ContiguousListSlice {
  public subscript(idx: Int) -> Element {
    get { return contents[contents.endIndex.predecessor() - idx] }
    set { contents[contents.endIndex.predecessor() - idx] = newValue }
  }
}

extension ContiguousListSlice {
  public subscript(idxs: Range<Int>) -> ContiguousListSlice<Element> {
    get {
      let start = contents.endIndex - idxs.endIndex
      let end = contents.endIndex - idxs.startIndex
      return ContiguousListSlice(contents: contents[start..<end] )
    } set {
      let start = contents.endIndex - idxs.endIndex
      let end = contents.endIndex - idxs.startIndex
      contents[start..<end] = newValue.contents
    }
  }
}

extension ContiguousList {
  public func reverse() -> ContiguousArray<Element> {
    return contents
  }
}

extension ContiguousListSlice {
  public func reverse() -> ArraySlice<Element> {
    return contents
  }
}

extension ContiguousList {
  public mutating func replaceRange<
    C : CollectionType where C.Generator.Element == Element
    >(subRange: Range<ContiguousListIndex>, with newElements: C) {
      let start = subRange.endIndex.val.successor()
      let end   = subRange.startIndex.val.successor()
      contents.replaceRange((start..<end), with: newElements)
  }
}

extension ContiguousListSlice {
  public mutating func replaceRange<
    C : CollectionType where C.Generator.Element == Element
    >(subRange: Range<ContiguousListIndex>, with newElements: C) {
      let start = subRange.endIndex.val.successor()
      let end   = subRange.startIndex.val.successor()
      contents.replaceRange((start..<end), with: newElements)
  }
}