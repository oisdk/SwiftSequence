/// :nodoc:
public struct ComboGen<SubElement> : GeneratorType {
  
  private let coll: [SubElement]
  private var curr: [SubElement]
  private var inds: [Int]
  /// :nodoc:
  mutating public func next() -> [SubElement]? {
    for (max, curInd) in zip(coll.indices.reverse(), inds.indices.reverse())
      where max != inds[curInd] {
        curr[curInd] = coll[++inds[curInd]]
        for j in inds.indices.suffixFrom(curInd+1) {
          inds[j] = inds[j-1].successor()
          curr[j] = coll[inds[j]]
        }
        return curr
    }
    return nil
  }
}
/// :nodoc:
public struct ComboSeq<Element> : LazySequenceType {
  
  private let start: [Element]
  private let col  : [Element]
  private let inds : [Int]
  /// :nodoc:
  public func generate() -> ComboGen<Element> {
    return ComboGen<Element>(coll: col, curr: start, inds: inds)
  }
  
  internal init(n: Int, col: [Element]) {
    self.col = col
    start = Array(col.prefixUpTo(n))
    var inds = Array(col.indices.prefixUpTo(n))
    if !inds.isEmpty { --inds[n.predecessor()] }
    self.inds = inds
  }
}
/// :nodoc:
public struct ComboRepGen<Element> : GeneratorType {
  
  private let coll: [Element]
  private var curr: [Element]
  private var inds: [Int]
  private let max : Int
  /// :nodoc:
  mutating public func next() -> [Element]? {
    for curInd in inds.indices.reverse() where max != inds[curInd] {
      curr[curInd] = coll[++inds[curInd]]
      for j in (curInd+1)..<inds.count {
        inds[j] = inds[j-1]
        curr[j] = coll[inds[j]]
      }
      return curr
    }
    return nil
  }
}
/// :nodoc:
public struct ComboRepSeq<Element> : LazySequenceType {
  
  private let start: [Element]
  private let inds : [Int]
  private let col  : [Element]
  private let max  : Int
  /// :nodoc:
  public func generate() -> ComboRepGen<Element> {
    return ComboRepGen(coll: col, curr: start, inds: inds, max: max)
  }
  
  internal init(n: Int, col: [Element]) {
    self.col = col
    start = col.first.map { x in Array(count: n, repeatedValue: x) } ?? []
    var inds = Array(count: n, repeatedValue: col.startIndex)
    if !inds.isEmpty { --inds[n-1] }
    self.inds = inds
    max = col.endIndex.predecessor()
  }
}


extension SequenceType {
  /**
  Returns the combinations without repetition of length `n` of `self`
  */
  @warn_unused_result
  public func combos(n: Int) -> [[Generator.Element]] {
    return Array(ComboSeq(n: n, col: Array(self)))
  }
  /**
  Returns the combinations with repetition of length `n` of `self`
  */
  @warn_unused_result
  public func combosWithRep(n: Int) -> [[Generator.Element]] {
    return Array(ComboRepSeq(n: n, col: Array(self)))
  }
  /**
  Returns the combinations without repetition of length `n` of `self`, generated lazily
  and on-demand
  */
  @warn_unused_result
  public func lazyCombos(n: Int) -> ComboSeq<Generator.Element> {
    return ComboSeq(n: n, col: Array(self))
  }
  /**
  Returns the combinations with repetition of length `n` of `self`, generated lazily and
  on-demand
  */
  @warn_unused_result
  public func lazyCombosWithRep(n: Int) -> ComboRepSeq<Generator.Element> {
    return ComboRepSeq(n: n, col: Array(self))
  }
}