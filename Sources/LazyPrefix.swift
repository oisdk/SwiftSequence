// MARK: LazyPrefix

import Foundation


/// :nodoc:
public struct LazyPrefixSeq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let take: Int
  /// :nodoc:
  public func generate() -> LazyPrefixGen<S.Generator> {
    return LazyPrefixGen(g: seq.generate(), take: take)
  }
}

/// :nodoc:
public struct LazyPrefixGen<G : GeneratorType> : GeneratorType {
  
  private var g: G
  private let take: Int
  private var found: Int
  
  init(g: G, take: Int) {
    self.g = g
    self.take = take
    self.found = 0
  }
  
  /// :nodoc:
  mutating public func next() -> G.Element? {
    
    guard found < take else {
      return nil
    }
    
    guard let next = g.next() else {
      return nil
    }
    
    found++
    return next
  }
}




public extension LazySequenceType {
  
  /// Returns a lazy sequence of self with the first n elements (useful if chained with filter)
  /// ```swift
  /// [1, 2, 3, 4, 5, 6, 7, 8].lazy.filter { $0 > 2 }.lazyPrefix(2)
  ///
  /// 3, 4
  /// ```
  @warn_unused_result
  func lazyPrefix(take: Int) -> LazyPrefixSeq<Self> {
    return LazyPrefixSeq(seq: self, take: take)
  }
}
