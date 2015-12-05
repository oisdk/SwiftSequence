// IntervalTypes

public protocol OpenIntervalType {
  typealias Value
  func contains(v: Value) -> Bool
}
public protocol OpenEndedIntervalType: OpenIntervalType {
  typealias Value: Comparable
  var val: Value { get }
}
public protocol OpenStartedIntervalTypeTo: OpenIntervalType {
  typealias Value: Comparable
  var val: Value { get }
}
public protocol OpenStartedIntervalTypeThrough: OpenIntervalType {
  typealias Value: Comparable
  var val: Value { get }
}

// Interval Structs

public struct OpenEndedInterval<C: Comparable>: OpenEndedIntervalType {
  public let val: C
}
public struct OpenStartedIntervalTo<C: Comparable>: OpenStartedIntervalTypeTo {
  public let val: C
}
public struct OpenStartedIntervalThrough<C: Comparable>: OpenStartedIntervalTypeThrough {
  public let val: C
}

// Range structs

public struct OpenEndedRange<I: ForwardIndexType where I: Comparable>: OpenEndedIntervalType {
  public var val: I
}
public struct OpenStartedRangeTo<I: BidirectionalIndexType where I: Comparable>: OpenStartedIntervalTypeTo {
  public var val: I
}
public struct OpenStartedRangeThrough<I: BidirectionalIndexType where I: Comparable>: OpenStartedIntervalTypeThrough {
  public var val: I
}

// Generators

public struct EndlessIncrement<I: ForwardIndexType>: GeneratorType {
  private var i: I
  public mutating func next() -> I? {
    defer { i = i.successor() }
    return i
  }
}

// SequenceType

extension OpenEndedRange: SequenceType {
  public func generate() -> EndlessIncrement<I> {
    return EndlessIncrement(i: val)
  }
}

// Operators

postfix operator ... {}
prefix operator ... {}
prefix operator ..< {}

public postfix func ...<C: Comparable>(c: C) -> OpenEndedInterval<C> {
  return OpenEndedInterval(val: c)
}
public postfix func ...<I: ForwardIndexType>(c: I) -> OpenEndedRange<I> {
  return OpenEndedRange(val: c)
}
public prefix func ..<<C: Comparable>(c: C) -> OpenStartedIntervalTo<C> {
  return OpenStartedIntervalTo(val: c)
}
public prefix func ..<<C: BidirectionalIndexType>(c: C) -> OpenStartedRangeTo<C> {
  return OpenStartedRangeTo(val: c)
}
public prefix func ... <C: Comparable>(c: C) -> OpenStartedIntervalThrough<C> {
  return OpenStartedIntervalThrough(val: c)
}
public prefix func ... <C: BidirectionalIndexType>(c: C) -> OpenStartedRangeThrough<C> {
  return OpenStartedRangeThrough(val: c)
}

// Contains

extension OpenEndedIntervalType {
  public func contains(v: Value) -> Bool { return val <= v }
}
extension OpenStartedIntervalTypeTo {
  public func contains(v: Value) -> Bool { return val > v }
}
extension OpenStartedIntervalTypeThrough {
  public func contains(v: Value) -> Bool { return val >= v }
}

// Pattern Matching

func ~=<I: OpenIntervalType>(lhs: I, rhs: I.Value) -> Bool {
  return lhs.contains(rhs)
}

// Indexing

extension CollectionType where Index: Comparable {
  subscript(r: OpenEndedRange<Index>) -> SubSequence {
    return suffixFrom(r.val)
  }
}

extension CollectionType where Index: Comparable, Index: BidirectionalIndexType {
  subscript(r: OpenStartedRangeTo<Index>) -> SubSequence {
    return prefixUpTo(r.val)
  }
  subscript(r: OpenStartedRangeThrough<Index>) -> SubSequence {
    return prefixThrough(r.val)
  }
}

extension MutableCollectionType where Index: Comparable {
  subscript(r: OpenEndedRange<Index>) -> SubSequence {
    get { return suffixFrom(r.val) }
    set { self[r.val..<endIndex] = newValue }
  }
}

extension MutableCollectionType where Index: Comparable, Index: BidirectionalIndexType {
  subscript(r: OpenStartedRangeTo<Index>) -> SubSequence {
    get { return prefixUpTo(r.val) }
    set { self[startIndex..<r.val] = newValue }
  }
  subscript(r: OpenStartedRangeThrough<Index>) -> SubSequence {
    get { return prefixThrough(r.val) }
    set { self[startIndex...r.val] = newValue }
  }
}
//
//// Hopping
//
//public struct RandomAccessHopCollection<
//  Base: CollectionType where
//  Base.Index : RandomAccessIndexType,
//  Base.Index.Distance : ForwardIndexType
//  >: LazyCollectionType {
//  
//  private let base: Base
//  private let by  : Base.Index.Stride
//  private let fac : Base.Index.Distance
//  
//  public var startIndex: Base.Index.Distance { return 0 }
//  public let endIndex: Base.Index.Distance
//  
//  public subscript(i: Base.Index.Distance) -> Base.Generator.Element {
//    return base[base.startIndex.advancedBy(fac * i)]
//  }
//  
//  private init(_ b: Base, _ by: Base.Index.Stride) {
//    base = b
//    self.by = by
//    fac = base.startIndex.distanceTo(base.startIndex.advancedBy(by))
//    endIndex = (base.startIndex.distanceTo(base.endIndex.predecessor()) / fac).successor()
//  }
//}
//
//extension CollectionType where Index: RandomAccessIndexType, Index.Distance: ForwardIndexType {
//  public subscript(by by: Index.Stride) -> RandomAccessHopCollection<Self> {
//    return RandomAccessHopCollection(self, by)
//  }
//}
//
//extension RandomAccessHopCollection: CustomStringConvertible, CustomDebugStringConvertible {
//  public var debugDescription: String {
//    return Array(self).debugDescription
//  }
//  public var description: String {
//    return String(Array(self))
//  }
//}
//
//extension CollectionType where
//  SubSequence: CollectionType,
//  Index == SubSequence.Index,
//  SubSequence.Index: RandomAccessIndexType,
//SubSequence.Index.Distance: ForwardIndexType {
//  subscript(r: OpenEndedInterval<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
//    return suffixFrom(r.val)[by: by]
//  }
//  subscript(r: OpenStartedIntervalTo<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
//    return prefixUpTo(r.val)[by: by]
//  }
//  subscript(r: OpenStartedIntervalThrough<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
//    return prefixThrough(r.val)[by: by]
//  }
//  subscript(r: OpenEndedRange<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
//    return suffixFrom(r.val)[by: by]
//  }
//  subscript(r: OpenStartedRangeTo<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
//    return prefixUpTo(r.val)[by: by]
//  }
//  subscript(r: OpenStartedRangeThrough<Index>, by by: Index.Stride) -> RandomAccessHopCollection<SubSequence> {
//    return prefixThrough(r.val)[by: by]
//  }
//}