// MARK: Categorise
// MARK: ChunkWindowSplit
extension LazyList {
  private func split(n: Int) -> (LazyList<Element>, LazyList<Element>) {
    switch (n, self) {
    case (0, _), (_, .Nil): return (.Nil, self)
    case (_, let .Cons(head, tail)): return {(head |> $0.0, $0.1)}(tail().split(n - 1))
    }
  }
  public func chunk(n: Int) -> LazyList<LazyList<Element>> {
    switch self {
    case .Nil: return .Nil
    case .Cons: return {$0.0 |> $0.1.chunk(n)}(split(n))
    }
  }
}

extension LazyList {
  
  private func takeIfAvailable(n: Int) -> LazyList<Element>? {
    switch (n, self) {
    case (0, _): return .Nil
    case (_, .Nil): return nil
    case let (_, .Cons(h, t)): return t().takeIfAvailable(n - 1).map { h |> $0 }
    }
  }
  
  public func window(n: Int) -> LazyList<LazyList<Element>> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(_, tail): return takeIfAvailable(n).map { $0 |> tail().window(n) } ?? .Nil
    }
  }
}

extension LazyList {
  private func split(isSplit: Element -> Bool) -> (LazyList<Element>, LazyList<Element>) {
    switch self {
    case .Nil: return (.Nil, .Nil)
    case let .Cons(head, tail):
      return isSplit(head) ? ([head], tail()) :
        {(head |> $0.0, $0.1)}(tail().split(isSplit))
    }
  }
  public func splitAt(isSplit: Element -> Bool) -> LazyList<LazyList<Element>> {
    switch self {
    case .Nil:  return .Nil
    case .Cons: return { $0.0 |> $0.1.splitAt(isSplit) }(split(isSplit))
    }
  }
}
// MARK: Combinations
// MARK: Cycle
extension LazyList {
  public func cycle() -> LazyList<Element> {
    return self.extended(self.cycle())
  }
}
extension LazyList {
  func cycle(n: Int) -> LazyList<Element> {
    return LazyList<Int>(0..<n).flatMap { _ in self }
  }
}
// MARK: Enumerate
// MARK: Finding
// MARK: HopJump
public extension LazyList {
  public func hop(n: Int, i: Int = 1) -> LazyList<Element> {
    switch (i, self) {
    case (1, let .Cons(head, tail)): return head |> tail().hop(n, i: n)
    case (_, .Cons(_, let tail)): return tail().hop(n, i: i - 1)
    case (_, .Nil): return .Nil
    }
  }
}
// MARK: Interpose
extension LazyList {
  private func prependtoAll(with: Element) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return with |> head |> tail().prependtoAll(with)
    }
  }
}

extension LazyList {
  public func interpose(element: Element) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return head |> tail().prependtoAll(element)
    }
  }
}

extension LazyList {
  private func prependtoAll(with: LazyList<Element>) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return with.extended(head |> tail().prependtoAll(with))
    }
  }
}

extension LazyList {
  public func interpose(with: LazyList<Element>) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return head |> tail().prependtoAll(with)
    }
  }
}

public func interdig<T>(s0: LazyList<T>, _ s1: LazyList<T>) -> LazyList<T> {
  switch (s0, s1) {
  case let (.Cons(h0, t0), .Cons(h1, t1)): return h0 |> h1 |> interdig(t0(), t1())
  case let(.Cons(h0, _), _): return h0 |> .Nil
  default: return .Nil
  }
}
// MARK: NestedSequences
// MARK: Permutations
// MARK: ScanReduce
extension LazyList {
  public func scan<T>(initial: T, combine: (accumulator: T, element: Element) -> T) -> LazyList<T> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail):
      let tHead = combine(accumulator: initial, element: head)
      return tHead |> tail().scan(tHead, combine: combine)
    }
  }
  public func scan(combine: (accumulator: Element, element: Element) -> Element) -> LazyList<Element> {
    switch self {
    case .Nil: return .Nil
    case let .Cons(head, tail): return tail().scan(head, combine: combine)
    }
  }
}
// MARK: TakeDrop
extension LazyList {
  public func takeWhile(condition: Element -> Bool) -> LazyList<Element> {
    switch self {
    case .Nil: return self
    case let .Cons(head, tail):
      return condition(head) ? (head |> tail().takeWhile(condition)) : .Nil
    }
  }
  public func dropWhile(@noescape condition: Element -> Bool) -> LazyList<Element> {
    switch self {
    case .Nil: return self
    case let .Cons(head, tail):
      return condition(head) ? tail().dropWhile(condition) : (head |> tail())
    }
  }
}
// MARK: Zip
public func zip<A, B>(s0: LazyList<A>, _ s1: LazyList<B>) -> LazyList<(A, B)> {
  switch (s0, s1) {
  case let (.Cons(h0, t0), .Cons(h1, t1)): return (h0, h1) |> zip(t0(), t1())
  default: return .Nil
  }
}
public func zip<A, B>(s0: LazyList<A>, _ s1: LazyList<B>, pad0: A, pad1: B) -> LazyList<(A, B)> {
  switch (s0, s1) {
  case let (.Cons(h0, t0), .Cons(h1, t1)): return (h0, h1) |> zip(t0(), t1(), pad0: pad0, pad1: pad1)
  case let (.Cons(h0, t0), .Nil): return (h0, pad1) |> zip(t0(), .Nil, pad0: pad0, pad1: pad1)
  case let (.Nil, .Cons(h1, t1)): return (pad0, h1) |> zip(.Nil, t1(), pad0: pad0, pad1: pad1)
  default: return .Nil
  }
}