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

extension ContiguousList : ArrayLiteralConvertible {
  public init(arrayLiteral: Element...) {
    contents = ContiguousArray(arrayLiteral.reverse())
  }
}

extension ContiguousList {
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
      return ContiguousListSlice(contents:
        contents[idxs.endIndex.val.successor()..<idxs.startIndex.val.successor()]
      )
    } set {
      contents[idxs.endIndex.val.successor()..<idxs.startIndex.val.successor()] =
        newValue.contents
    }
  }
}

extension ContiguousListSlice {
  public subscript(idxs: Range<ContiguousListIndex>) -> ContiguousListSlice<Element> {
    get {
      return ContiguousListSlice(contents:
        contents[idxs.endIndex.val.successor()..<idxs.startIndex.val.successor()]
      )
    } set {
      contents[idxs.endIndex.val.successor()..<idxs.startIndex.val.successor()] =
        newValue.contents
    }
  }
}

extension ContiguousList {
  init() {
    contents = []
  }
}

extension ContiguousListSlice {
  init() {
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
  mutating func prepend(with: Element) {
    contents.append(with)
  }
}

extension ContiguousListSlice {
  mutating func prepend(with: Element) {
    contents.append(with)
  }
}

extension ContiguousList {
  mutating func reserveCapacity(n: Int) {
    contents.reserveCapacity(n)
  }
}

extension ContiguousListSlice {
  mutating func reserveCapacity(n: Int) {
    contents.reserveCapacity(n)
  }
}

extension ContiguousList {
  subscript(idx: Int) -> Element {
    get { return contents[contents.endIndex.predecessor() - idx] }
    set { contents[contents.endIndex.predecessor() - idx] = newValue }
  }
}

extension ContiguousList {
  subscript(idxs: Range<Int>) -> ContiguousListSlice<Element> {
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
  subscript(idx: Int) -> Element {
    get { return contents[contents.endIndex.predecessor() - idx] }
    set { contents[contents.endIndex.predecessor() - idx] = newValue }
  }
}

extension ContiguousListSlice {
  subscript(idxs: Range<Int>) -> ContiguousListSlice<Element> {
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

extension ContiguousList {
  func reverse() -> ContiguousArray<Element> {
    return contents
  }
}

extension ContiguousListSlice {
  func reverse() -> ArraySlice<Element> {
    return contents
  }
}

