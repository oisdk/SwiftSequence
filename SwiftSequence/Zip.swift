public struct NilPaddedZipGenerator<G0: GeneratorType, G1: GeneratorType> : GeneratorType {
  
  typealias E0 = G0.Element
  typealias E1 = G1.Element
  
  private var (g0, g1): (G0?, G1?)
  
  public mutating func next() -> (E0?, E1?)? {
    let e0: E0? = g0?.next() ?? {g0 = nil; return nil}()
    let e1: E1? = g1?.next() ?? {g1 = nil; return nil}()
    return (e0 != nil || e1 != nil) ? (e0, e1) : nil
  }
}

public struct NilPaddedZip<S0: SequenceType, S1: SequenceType> : LazySequenceType {
  
  private let (s0, s1): (S0, S1)
  
  public func generate() -> NilPaddedZipGenerator<S0.Generator, S1.Generator> {
    return NilPaddedZipGenerator(g0: s0.generate(), g1: s1.generate())
  }
}

/// A sequence of pairs built out of two underlying sequences, where the elements of the
/// ith pair are optional ith elements of each underlying sequence. If one sequence is
/// shorter than the other, pairs will continue to be returned after it is exhausted, but
/// with its elements replaced by nil.
/// ```swift
/// zipWithPadding([1, 2, 3], [1, 2])
///
/// (1?, 1?), (2?, 2?), (3?, nil)
/// ```

public func zipWithPadding<S0: SequenceType, S1: SequenceType>(s0: S0, _ s1: S1)
  -> NilPaddedZip<S0, S1> {
    return NilPaddedZip(s0: s0, s1: s1)
}

public struct PaddedZipGenerator<G0: GeneratorType, G1: GeneratorType> : GeneratorType {
  
  typealias E0 = G0.Element
  typealias E1 = G1.Element
  
  private var (g0, g1): (G0?, G1?)
  private let (p0, p1): (E0, E1)
  
  public mutating func next() -> (E0, E1)? {
    let e0: E0? = g0?.next() ?? {g0 = nil; return nil}()
    let e1: E1? = g1?.next() ?? {g1 = nil; return nil}()
    return (e0 != nil || e1 != nil) ? (e0 ?? p0, e1 ?? p1) : nil
  }
}

public struct PaddedZip<S0: SequenceType, S1: SequenceType> : LazySequenceType {
  
  private let (s0, s1): (S0, S1)
  private let (p0, p1): (S0.Generator.Element, S1.Generator.Element)
  
  public func generate() -> PaddedZipGenerator<S0.Generator, S1.Generator> {
    return PaddedZipGenerator(g0: s0.generate(), g1: s1.generate(), p0: p0, p1: p1)
  }
}

/// A sequence of pairs built out of two underlying sequences, where the elements of the
/// ith pair are the ith elements of each underlying sequence. If one sequence is
/// shorter than the other, pairs will continue to be returned after it is exhausted, but
/// with its elements replaced by its respective pad.
/// - Parameter pad0: the element to pad `s0` with after it is exhausted
/// - Parameter pad1: the element to pad `s1` with after it is exhausted
/// ```swift
/// zipWithPadding([1, 2, 3], [1, 2], pad0: 100, pad1: 900)
///
/// (1, 1), (2, 2), (3, 900)
/// ```

public func zipWithPadding<
  S0: SequenceType, S1: SequenceType
  >(s0: S0, _ s1: S1, pad0: S0.Generator.Element, pad1: S1.Generator.Element)
  -> PaddedZip<S0, S1> {
    return PaddedZip(s0: s0, s1: s1, p0: pad0, p1: pad1)
}

// MARK: List




