public extension SequenceType {
  
  /// Returns the first element in self that satisfies a predicate, or nil if it doesn't
  /// exist
  
  func first(@noescape predicate: Generator.Element -> Bool) -> Generator.Element? {
    for el in self where predicate(el) { return el }
    return nil
  }
  
  /// Returns the number of elements in `self` that satisfy `predicate`
  
  func count(@noescape predicate: Generator.Element -> Bool) -> Int {
    var i = 0
    for el in self where predicate(el) { ++i }
    return i
  }
}
  
public extension CollectionType where Index : BidirectionalIndexType {

  
  /// Returns the last element in self that satisfies a predicate, or nil if it doesn't
  /// exist
  
  func last(@noescape predicate: Generator.Element -> Bool) -> Generator.Element? {
    for el in reverse() where predicate(el) { return el }
    return nil
  }
}

extension CollectionType {
  /**
  Returns the indices of elements of `self` that satisfy the predicate `isElement`
  */
  
  func indicesOf(@noescape isElement: Generator.Element -> Bool) -> [Index] {
    return indices.filter { i in isElement(self[i]) }
  }
}