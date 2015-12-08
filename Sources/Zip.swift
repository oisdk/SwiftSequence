/// :nodoc:
public struct NilPaddedZipGenerator<G0: GeneratorType, G1: GeneratorType> : GeneratorType {
  
  private var (g0, g1): (G0?, G1?)
  
  public mutating func next() -> (G0.Element?, G1.Element?)? {
    let (e0,e1) = (g0?.next(),g1?.next())
    switch (e0,e1) {
    case (nil,nil): return nil
    case (  _,nil): g1 = nil
    case (nil,  _): g0 = nil
    default: break
    }
    return (e0,e1)
  }
}
/// :nodoc:
public struct NilPaddedZip<S0: SequenceType, S1: SequenceType> : LazySequenceType {
  
  private let (s0, s1): (S0, S1)
  /// :nodoc:
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
@warn_unused_result
public func zipWithPadding<S0: SequenceType, S1: SequenceType>(s0: S0, _ s1: S1)
  -> NilPaddedZip<S0, S1> {
    return NilPaddedZip(s0: s0, s1: s1)
}
/// :nodoc:
public struct PaddedZipGenerator<G0: GeneratorType, G1: GeneratorType> : GeneratorType {
  
  typealias E0 = G0.Element
  typealias E1 = G1.Element
  
  private var g: NilPaddedZipGenerator<G0, G1>
  private let (p0, p1): (E0, E1)

  public mutating func next() -> (E0, E1)? {
    guard let (e0,e1) = g.next() else { return nil }
    return (e0 ?? p0, e1 ?? p1)
  }
}
/// :nodoc:
public struct PaddedZip<S0: SequenceType, S1: SequenceType> : LazySequenceType {
  
  private let (s0, s1): (S0, S1)
  private let (p0, p1): (S0.Generator.Element, S1.Generator.Element)
  /// :nodoc:
  public func generate() -> PaddedZipGenerator<S0.Generator, S1.Generator> {
    return PaddedZipGenerator(
      g: NilPaddedZipGenerator(
        g0: s0.generate(),
        g1: s1.generate()
      ),
      p0: p0,
      p1: p1
    )
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
@warn_unused_result
public func zipWithPadding<
  S0: SequenceType, S1: SequenceType
  >(s0: S0, _ s1: S1, pad0: S0.Generator.Element, pad1: S1.Generator.Element)
  -> PaddedZip<S0, S1> {
    return PaddedZip(s0: s0, s1: s1, p0: pad0, p1: pad1)
}
