/// :nodoc:
public struct ComboGen<Element> : GeneratorType {
  
  private let coll: [Element]
  private var curr: [Element]
  private var inds: [Int]
  
  mutating public func next() -> [Element]? {
    guard inds.count > 1 else {
      if inds.isEmpty {
        inds = [coll.endIndex]
        return []
      }
      return { $0 == coll.endIndex ? nil : [coll[$0]] } (inds[0]++)
    }
    for (max, curInd) in zip(coll.indices.reverse(), inds.indices.reverse())
      where max != inds[curInd] {
        curr[curInd] = coll[++inds[curInd]]
        for j in (curInd+1)..<inds.count {
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
  private let inds : [Int]
  private let col  : [Element]
  
  public func generate() -> ComboGen<Element> {
    return ComboGen(coll: col, curr: start, inds: inds)
  }
  
  internal init(n: Int, col: [Element]) {
    self.col = col
    start = Array(col.prefixUpTo(n))
    let i = n.predecessor()
    guard i > 0 else {self.inds = []; return}
    inds = Array((col.startIndex..<i) + [n < col.count ? i.predecessor() : col.startIndex])
  }
}
/// :nodoc:
public struct ComboRepGen<Element> : GeneratorType {
  
  private let coll: [Element]
  private var curr: [Element]
  private var inds: [Int]
  private let max : Int
  
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
  public func combos(n: Int) -> [[Generator.Element]] {
    return Array(ComboSeq(n: n, col: Array(self)))
  }
  /**
  Returns the combinations with repetition of length `n` of `self`
  */
  public func combosWithRep(n: Int) -> [[Generator.Element]] {
    return Array(ComboRepSeq(n: n, col: Array(self)))
  }
  /**
  Returns the combinations without repetition of length `n` of `self`, generated lazily
  and on-demand
  */
  public func lazyCombos(n: Int) -> ComboSeq<Generator.Element> {
    return ComboSeq(n: n, col: Array(self))
  }
  /**
  Returns the combinations with repetition of length `n` of `self`, generated lazily and
  on-demand
  */
  public func lazyCombosWithRep(n: Int) -> ComboRepSeq<Generator.Element> {
    return ComboRepSeq(n: n, col: Array(self))
  }
}