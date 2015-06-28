public extension SequenceType {
  
  /// Returns the first element in self that satisfies a predicate, or nil if it doesn't
  /// exist
  
  func first(predicate: Generator.Element -> Bool) -> Generator.Element? {
    for el in self where predicate(el) { return el }
    return nil
  }
}
  
public extension CollectionType {

  
  /// Returns the last element in self that satisfies a predicate, or nil if it doesn't
  /// exist
  
  func last(predicate: Generator.Element -> Bool) -> Generator.Element? {
    for el in lazy(self).reverse() where predicate(el) { return el }
    return nil
  }
}