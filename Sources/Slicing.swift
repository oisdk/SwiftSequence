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

public func ~=<I: OpenIntervalType>(lhs: I, rhs: I.Value) -> Bool {
  return lhs.contains(rhs)
}

// Indexing

public extension CollectionType where Index: Comparable {
  subscript(r: OpenEndedRange<Index>) -> SubSequence {
    return suffixFrom(r.val)
  }
}

public extension CollectionType where Index: Comparable, Index: BidirectionalIndexType {
  subscript(r: OpenStartedRangeTo<Index>) -> SubSequence {
    return prefixUpTo(r.val)
  }
  subscript(r: OpenStartedRangeThrough<Index>) -> SubSequence {
    return prefixThrough(r.val)
  }
}

public extension MutableCollectionType where Index: Comparable {
  subscript(r: OpenEndedRange<Index>) -> SubSequence {
    get { return suffixFrom(r.val) }
    set { self[r.val..<endIndex] = newValue }
  }
}

public extension MutableCollectionType where Index: Comparable, Index: BidirectionalIndexType {
  subscript(r: OpenStartedRangeTo<Index>) -> SubSequence {
    get { return prefixUpTo(r.val) }
    set { self[startIndex..<r.val] = newValue }
  }
  subscript(r: OpenStartedRangeThrough<Index>) -> SubSequence {
    get { return prefixThrough(r.val) }
    set { self[startIndex...r.val] = newValue }
  }
}