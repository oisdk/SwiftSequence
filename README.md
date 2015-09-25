[![Build Status](https://travis-ci.org/oisdk/SwiftSequence.svg?branch=master)](https://travis-ci.org/oisdk/SwiftSequence) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# SwiftSequence

(If you're looking for data structures in Swift, those have been moved to [here](https://github.com/oisdk/SwiftDataStructures))

SwiftSequence is a lightweight framework of extensions to `SequenceType`. It has no requirements beyond the Swift standard library. Every function and method has both a strict and a lazy version, unless otherwise specified.

To make an eager sequence lazy, the `lazy` property can be used:

```swift
[1, 2, 3].lazy.hop(2)

// 1, 3
```

## Contents ##

- [Extensions] (#extensions)
  - [ScanReduce] (#scanreduce)
  - [TakeDrop] (#takedrop)
  - [HopJump] (#hopjump)
  - [Interpose] (#interpose)
  - [Combinations] (#combinations)
  - [Permutations] (#permutations)
  - [Cycle] (#cycle)
  - [Categorise] (#categorise)
  - [ChunkWindowSplit] (#chunkwindowsplit)
  - [Enumerate] (#enumerate)
  - [Finding] (#finding)
  - [NestedSequences] (#nestedsequences)
  - [Zip] (#zip)

# Extensions #

## ScanReduce ##

### Reduce ###

```swift
func reduce
    (@noescape combine: (accumulator: Generator.Element, element: Generator.Element) throws -> Generator.Element)
    rethrows -> Generator.Element?
```
 Return the result of repeatedly calling combine with an accumulated value
 initialised to the first element of self and each element of self, in turn, i.e.

 ```swift
 [1, 2, 3].reduce(+) // 6
 ```

This function works the same as the standard library reduce, except it takes the initial value to be the first element of `self`. It returns an optional, which is `nil` if `self` is empty.

### Scan ###
Return an array where every value is equal to combine called on the previous element, and the current element. The first element is taken to be initial.

```swift
[1, 2, 3].scan(0, combine: +)
 
[1, 3, 6]
```

There is also, like reduce, a version that takes the first element of the sequence to be `initial`:

```swift
[1, 2, 3, 4, 5].scan(+)

[3, 6, 10, 15]
```

This also is evaluated lazily if the sequence it is called on is lazy.

## TakeDrop ##

### prefixWhile ###

This function returns all of the elements of `self` up until an element returns false for `predicate`:

```swift
[1, 2, 3, 4, 5, 2].prefixWhile { $0 < 4 }

[1, 2, 3]
```

Note that it's not the same as filter: if any elements return true for the predicate *after* the first element that returns false, they're still not returned.

### DropWhile ###

Similar in behaviour to `prefixWhile`, this function drops the first elements of `self` that return true for a predicate:

```swift
lazy([1, 2, 3, 4, 5, 2]).dropWhile { $0 < 4 }

4, 5, 2
```

## Hop ##

Similar to Python's slicing, this returns a sequence made by walking
over the underlying sequence with hops of length `n`

```swift
[1, 2, 3, 4, 5, 6, 7, 8].hop(3)

[1, 4, 7]
```

## Interpose ##

These functions allow lazy and eager insertion of elements into sequences at regular intervals.

### Interpose ###

This function returns `self`, with `element` inserted between every element:

```swift
[1, 2, 3].interpose(10)

[1, 10, 2, 10, 3]
```

The intervals at which to insert `element` can be specified:

```swift
[1, 2, 3, 4, 5].interpose(10, n: 2)

[1, 2, 10, 3, 4, 10, 5]
```

More than one element can be interposed:

```swift
[1, 2, 3].interpose([10, 20])

[1, 10, 20, 2, 10, 20, 3]
```

And, again, the interval can be specified:

```swift
[1, 2, 3, 4, 5].interpose([10, 20], n: 2)

[1, 2, 10, 20, 3, 4, 10, 20, 5]
```

### interdig ###

This function allows you to combine two sequences by alternately selecting elements from each:

```swift
interdig([1, 2, 3], [10, 20, 30])

[1, 10, 2, 20, 3, 30]
```

The length of the interdigitations can be specified:

```swift
interdig([1, 2, 3, 4, 5], [10, 20, 30, 40, 50, 60], s0Len: 2, s1Len: 3)

[1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5]
```

## Combinations ##

These functions return combinations with or without repetition, lazily or eagerly. The lazy version of these function doesn't maintain laziness of the underlying sequence, but they produce combinations on-demand, with neither future nor past combinations stored in memory, e.g:

```swift

let lazySequence = lazy([1, 2, 3])

let lazyCombos = lazySequence.lazyCombinations(2)

// Here, lazySequence was evaluated, but no combinations have yet been evaluated.

var g = lazyCombos.generate()

g.next() // [1, 2]

// Here, only one combination has been evaluated, and only that combination is stored in memory

g.next() // [1, 3]

// Here, two combinations have been evaluated, but no extra combinations have been stored in memory.

```

### Combinations ###

Returns combinations without repetitions of self of length `n`

Combinations are returned in lexicographical order, according to the order of `self`

```swift
[1, 2, 3].combinations(2)

[1, 2], [1, 3], [2, 3]
```

To have combinations generate lazily and on-demand, use `lazyCombinations()`.

Example Recipe:

```swift
extension CollectionType {
  func powerSet() -> FlatMapSeq<LazyForwardCollection<Self>, ComboSeq<[Self.Generator.Element]>> {
    var i = 0
    return lazy(self).flatMap { _ in self.lazyCombinations(++i) }
  }
}

[1, 2, 3]       // [1], [2], [3], [1, 2], [1, 3], [2, 3], [1, 2, 3]
  .powerSet()
```

### Combinations with Repetition ###

Returns combinations with repetition of self of length `n`.

Combinations are returned in lexicographical order, according to the order of `self`.

```swift
[1, 2, 3].combinationsWithRep(2)

[1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]
```

To have combinations generate lazily and on-demand, use `lazyCombinationsWithRep()`.

## Permutations ##

### Lexicographical Permutations

These functions return `self`, permuted, in lexicographical order. If `self` is not the first permutation, lexicographically, not all permutations will be returned. (to ensure all permutations are returned, `sort()` can be used). This function can operate on a collection of `Comparable` elements, or, is the closure `isOrderedBefore` is provided, it can operate on any collection. In terms of laziness, it behaves the same as the combination functions: forcing the evaluation of the underlying collection, but capable of lazily producing each new permutation. To access the lazy version, use the versions of these functions with the `lazy` prefix. (e.g., `lexPermutations()` becomes `lazyLexPermutations()`)
```swift
[1, 2, 3].lexPermutations()

[[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
```
```swift
[3, 2, 1].lexPermutations()

[[3, 2, 1]]
```

```swift
[1, 2, 3].lexPermutations(<)

[[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
```
```swift
[1, 2, 3].lexPermutations(>)

[[1, 2, 3]]
```

### Permutations ###

These functions use the same algorithm as the lexicographical permutations, but the indices of self are permuted. (Indices aren't returned: they're just used for the permutation)

```swift
[1, 2, 3].permutations()

[[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
```
```swift
lazy([3, 2, 1]).lazyPermutations()

[3, 2, 1], [3, 1, 2], [2, 3, 1], [2, 1, 3], [1, 3, 2], [1, 2, 3]
```


## Cycle ##

These functions return a cycle of self. The number of cycles can be specified, if not, `self` is cycled infinitely.

When called on a `LazySequenceType`, the sequence returned is lazy, otherwise, it's eager. (the infinite cycle is always lazy, however)

```swift
[1, 2, 3].cycle(2)

[1, 2, 3, 1, 2, 3]
```
```swift
[1, 2, 3].cycle()

1, 2, 3, 1, 2, 3, 1...
```

## Categorise ##

These functions can be used to group elements of a sequence on certain conditions.

### categorise ###

```swift
func categorise<U : Hashable>(keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] 
```

This categorises all elements of self into a dictionary, with the keys of that dictionary given by the `keyFunc`.

```swift
[1, 2, 3, 4, 5, 6].categorise { $0 % 2 }


[
  0: [2, 4, 6],
  1: [1, 3, 5]
]

```

(this function has no lazy version)

### Frequencies ###

This returns a dictionary where the keys are the elements of self, and the values are their respective frequencies:

```swift

[1, 1, 1, 2, 2, 3].freqs()

[
  1: 3,
  2: 2,
  3: 1
]

```

(this function has no lazy version)

### Uniques ###

Returns `self` with duplicates removed:

```swift
[1, 2, 3, 2, 2, 4, 1, 2, 5, 6].uniques()

[1, 2, 3, 4, 5, 6]
```

### Grouping ###

Since `categorise()` and `freqs()` can't have lazy versions, these grouping functions give similar behaviour. Instead of categorising based on the whole sequence, they categories based on *adjacent* values.

This groups adjacent equal values:

``` swift
lazy([1, 2, 2, 3, 1, 1, 3, 4, 2]).group()

[1], [2, 2], [3], [1, 1], [3], [4], [2]
```
This groups adjacent equal values according to a closure:

```swift
lazy([1, 3, 5, 20, 22, 18, 6, 7]).group { abs($0 - $1) < 5 }

[1, 3, 5], [20, 22, 18], [6, 7]
```

This groups adjacent values that return the same from `keyFunc`:

```swift
lazy([1, 3, 5, 2, 4, 6, 6, 7, 1, 1]).groupBy { $0 % 2 }

[1, 3, 5], [2, 4, 6, 6], [7, 1, 1]
```

## ChunkWindowSplit ##

These functions divide up a sequence.

### Chunk ###

This function returns `self`, broken up into non-overlapping arrays of length `n`:

```swift
[1, 2, 3, 4, 5].chunk(2)

[[1, 2], [3, 4], [5]]
```

### Window ###

This function returns `self`, broken up into overlapping arrays of length `n`:

```swift
[1, 2, 3, 4, 5].window(3)

[[1, 2, 3], [2, 3, 4], [3, 4, 5]]
```

## Enumerate ##

This just adds the function `specEnumerate()` which is the same as the standard library `enumerate()`, except that the indices it returns are specific to the base, rater than just `Int`s. So, for instance, this:

```swift
"hello".characters.specEnumerate()
```

Would return a sequence of `(String.Index, Character)` (rather than `(Int, Character)`, which is what the standard library `enumerate()` returns). There is no eager version of this function (as there is no eager `enumerate()`)

## Finding ##

There are two functions here, `first()` and `last()`. These return the first and the last element that satisfies the supplied predicate. (or nil if it doesn't exist)

```swift

[1, 2, 3, 4, 5].first { $0 > 3 }

4

```

```swift

[1, 2, 3, 4, 5].last { $0 < 5 }

4

```

## NestedSequences ##

### Transpose ###

Allows both lazy and eager transposition. When lazily transposing, each row is evaluated eagerly, but only that row:

```swift
let transposed = lazy([
  [1, 2, 3],
  [1, 2, 3],
  [1, 2, 3]
]).transpose()

var g = transposed.generate()

g.next() // [1, 1, 1]

// Each row is an eager array, but only that row is evaluated.

g.next() // [2, 2, 2]

// It's safe to use with single-pass sequences, also, as each sequence is only evaluated once.

```

### Product ###

Both lazy and eager Cartesian Products.

```swift
product([1, 2], [3, 4])

[[1, 3], [1, 4], [2, 3], [2, 4]]

lazyProduct([1, 2], [3, 4])

[1, 3], [1, 4], [2, 3], [2, 4]
```

## Zip ##

These functions allow you to zip two sequences of different lengths together, and to specify the padding for the shorter sequence. If unspecified, the padding is `nil`. There is no eager version of this function (there is no eager standard library zip)


```swift
zipWithPadding([1, 2, 3], [1, 2], pad0: 100, pad1: 900)

(1, 1), (2, 2), (3, 900)
```

```swift
zipWithPadding([1, 2, 3], [1, 2])

(1?, 1?), (2?, 2?), (3?, nil)
```
