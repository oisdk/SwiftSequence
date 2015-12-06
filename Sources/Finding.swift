prefix operator ! {}
public prefix func !<A>(f: A -> Bool) -> A -> Bool {
  return { x in !f(x) }
}

public extension SequenceType {
  
  /// Returns the first element in self that satisfies a predicate, or nil if it doesn't
  /// exist
  
  func first(@noescape thatSatisfies: Generator.Element throws -> Bool) rethrows -> Generator.Element? {
    for el in self where try thatSatisfies(el) { return el }
    return nil
  }
  
  /// Returns the number of elements in `self` that satisfy `predicate`
  
  func count(@noescape predicate: Generator.Element throws -> Bool) rethrows -> Int {
    var i = 0
    for el in self where try predicate(el) { i += 1 }
    return i
  }
  
  /// Returns true iff every element in `self` satisfies `predicate`
  
  func all(@noescape predicate: Generator.Element throws -> Bool) rethrows -> Bool {
    for x in self { guard try predicate(x) else { return false } }
    return true
  }
}
  
public extension CollectionType where Index : BidirectionalIndexType {

  
  /// Returns the last element in self that satisfies a predicate, or nil if it doesn't
  /// exist
  
  func last(@noescape predicate: Generator.Element throws -> Bool) rethrows -> Generator.Element? {
    for el in reverse() {
      if try predicate(el) {
        return el
      }
    }
    return nil
  }
  
  /**
  Returns the index of the final element in `self` which satisfies 
  `isElement`, or `nil` if it doesn't exist.
  */
  
  func lastIndexOf(@noescape isElement: Generator.Element throws -> Bool) rethrows -> Index? {
    for i in indices.reverse() where try isElement(self[i]) {
      return i
    }
    return nil
  }
}

extension CollectionType {
  /**
  Returns the indices of elements of `self` that satisfy the predicate `isElement`
  */
  
  func indicesOf(@noescape isElement: Generator.Element throws -> Bool) rethrows -> [Index] {
    return try indices.filter { i in try isElement(self[i]) }
  }
}

public extension SequenceType {
  func partition(@noescape predicate: Generator.Element throws -> Bool) rethrows -> ([Generator.Element], [Generator.Element]) {
    var t,f: [Generator.Element]
    (t,f) = ([],[])
    let c = underestimateCount()
    t.reserveCapacity(c)
    f.reserveCapacity(c)
    for e in self {
      if try predicate(e) { t.append(e) } else { f.append(e) }
    }
    return (t,f)
  }
}
