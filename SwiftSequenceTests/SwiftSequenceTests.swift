//
//  SwiftSequenceTests.swift
//  SwiftSequenceTests
//
//  Created by Donnacha Oisín Kidney on 28/06/2015.
//  Copyright © 2015 Donnacha Oisín Kidney. All rights reserved.
//

import XCTest

class SwiftSequenceTests: XCTestCase {
  
  // MARK: - Categorise
  
  // MARK: Eager
  
  func testCat() {
    
    let result = [1, 2, 3, 4, 5, 6].categorise {(i: Int) -> Int in i % 2 }
    
    let expectation = [0:[2, 4, 6], 1:[1, 3, 5]]
    
    for key in result.keys {
      XCTAssert(result[key]!.elementsEqual(expectation[key]!))
    }
  }
  
  func testFreqs() {
    
    let result = [1, 1, 1, 2, 2, 3].freqs()
    
    let expectation = [1:3, 2:2, 3:1]
    
    XCTAssert(result == expectation)
    
  }
  
  func testUniques() {
    
    let result = [1, 1, 1, 3, 3, 2, 4, 3].uniques()
    
    let expectation = [1, 3, 2, 4]
    
    XCTAssert(result == expectation)
    
  }
  
  func testReplace() {
    
    let replaced = [1, 2, 3, 4].replace([2:20, 3:30])
    
    let expectation = [1, 20, 30, 4]
    
    XCTAssert(replaced == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyUniques() {
    
    let uniqueSeq = lazy([1, 1, 1, 3, 3, 2, 4, 3]).uniques()
    
    let expectation = lazy([1, 3, 2, 4])
    
    XCTAssert(uniqueSeq.elementsEqual(expectation))
    
    let _ = uniqueSeq.array()
    
  }
  
  func testLazyReplace() {
    
    let replaceSeq = lazy([1, 2, 3, 4]).replace([2:20, 3:30])
    
    let expectation = lazy([1, 20, 30, 4])
    
    XCTAssert(replaceSeq.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = replaceSeq.array()
    
  }
  
  func testLazyGroup() {
    
    let groupSeq = lazy([1, 2, 2, 3, 1, 1, 3, 4, 2]).group()
    
    let expectation = lazy([[1], [2, 2], [3], [1, 1], [3], [4], [2]])
    
    XCTAssert(
      !zip(groupSeq, expectation).contains {
        a, b in
        a != b
      }
    )
    
    let _ = groupSeq.array()
    
  }
  
  func testLazyGroupClos() {
    
    let groupSeq = lazy([1, 3, 5, 20, 22, 18, 6, 7]).group { abs($0 - $1) < 5 }
    
    let expectation = lazy([[1, 3, 5], [20, 22, 18], [6, 7]])
    
    XCTAssert(
      !zip(groupSeq, expectation).contains {
        a, b in
        a != b
      }
    )
    
    let _ = groupSeq.array()

  }
  
  func testLazyKeyGroupBy() {
    
    let groupSeq = lazy([1, 3, 5, 2, 4, 6, 6, 7, 1, 1]).groupBy { $0 % 2 }
    
    let expectation = lazy([[1, 3, 5], [2, 4, 6, 6], [7, 1, 1]])
    
    XCTAssert(
      !zip(groupSeq, expectation).contains {
        a, b in
        a != b
      }
    )
    
    let _ = groupSeq.array()
    
  }
  
  // MARK: - ChunkWindowSplit
  
  // MARK: Eager
  
  func testChunk() {
    
    let chunkd = [1, 2, 3, 4, 5].chunk(2)
    
    let expectation = [[1, 2], [3, 4], [5]]
    
    XCTAssert(chunkd == expectation)
    
  }
  
  func testWindow() {
    
    let windowed = [1, 2, 3, 4, 5].window(3)
    
    let expectation = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
    
    XCTAssert(windowed == expectation)
    
  }
  
  func testSplit() {
    
    let splitted = [1, 2, 3, 4, 4, 5, 6].splitAt { $0 % 2 == 0 }
    
    let expectation =  [[1, 2], [3, 4], [4], [5, 6]]
    
    XCTAssert(splitted == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyChunk() {
    
    let chunkd = lazy([1, 2, 3, 4, 5]).chunk(2)
    
    let expectation = lazy([[1, 2], [3, 4], [5]])
    
    XCTAssert(chunkd.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = chunkd.array()
    
  }
  
  func testLazyWindow() {
    
    let windowed = lazy([1, 2, 3, 4, 5]).window(3)
    
    let expectation = lazy([[1, 2, 3], [2, 3, 4], [3, 4, 5]])
    
    XCTAssert(windowed.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = windowed.array()
    
  }
  
  func testLazySplit() {
    
    let splitted = lazy([1, 2, 3, 4, 4, 5, 6]).splitAt { $0 % 2 == 0 }
    
    let expectation =  lazy([[1, 2], [3, 4], [4], [5, 6]])
    
    XCTAssert(splitted.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = splitted.array()
    
  }
  
  // MARK: - Combinations
  
  // MARK: Eager
  
  func testCombosWithoutRep() {
    
    let comboed = [1, 2, 3].combinations(2)
    
    let expectation = [[1, 2], [1, 3], [2, 3]]
    
    XCTAssert(comboed == expectation)
    
  }
  
  func testCombosWithRep() {
    
    let comboed = [1, 2, 3].combinationsWithRep(2)
    
    let expectation = [[1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]]
    
    XCTAssert(comboed == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyCombosWithoutRep() {
    
    let comboed = [1, 2, 3].lazyCombinations(2)
    
    let expectation = lazy([[1, 2], [1, 3], [2, 3]])
    
    XCTAssert(comboed.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = comboed.array()
    
  }
  
  func testLazyCombosWithRep() {
    
    let comboed = [1, 2, 3].lazyCombinationsWithRep(2)
    
    let expectation = lazy([[1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]])
    
    XCTAssert(comboed.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = comboed.array()
    
  }
  
  // MARK: - Enumerate
  
  func testEnumerate() {
    
    let word = "hello".characters
    
    for (index, letter) in word.specEnumerate() {
      
      XCTAssert(word[index] == letter)
      
    }
  }
  
  // MARK: - Finding
  
  func testFindFirst() {
    
    let seq = [1, 2, 3, 4, 5, 6, 7, 8]
    
    XCTAssert( seq.first { $0 > 5 } == 6 )
    
  }
  
  func testFindLast() {
    
    let seq = [1, 2, 3, 4, 5, 6, 7, 8]
    
    XCTAssert( seq.last { $0 < 5 } == 4 )
    
  }
  
  func testCount() {
    
    let seq = [1, 2, 3, 4, 5, 6, 7, 8]
    
    XCTAssert(seq.count { $0 % 2 == 0} == 4)
    
  }
  
  // MARK: - FlatMap
  
  func testFlatMapSeq() {
    
    let seq = lazy([1, 2, 3, 4, 5])
    
    let flattened = seq.flatMap { [$0, 10] }
    
    let expectation = lazy([1, 10, 2, 10, 3, 10, 4, 10, 5, 10])
    
    XCTAssert(flattened.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = seq.array()
    
  }
  
  func testFlatMapOpt() {
    
    let seq = lazy([1, 2, 3, 4, 5])
    
    let flattened = seq.flatMap { $0 % 2 == 0 ? $0 / 2 : nil }
    
    let expectation = [1, 2]
    
    XCTAssert(flattened.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = seq.array()

  }
  
  // MARK: - GenericGenerators
  
  // MARK: Eager
  // MARK: Lazy
  
  // MARK: - Cycle
  
  // MARK: Eager
  
  func testCylceN() {
    
    let cycled = [1, 2, 3].cycle(2)
    
    let expectation = [1, 2, 3, 1, 2, 3]
    
    XCTAssert(cycled.elementsEqual(expectation, isEquivalent: ==))
    
  }
  
  // MARK: Lazy
  
  func testLazyCycleN() {
    
    let cycled = lazy([1, 2, 3]).cycle(2)
    
    let expectation = lazy([1, 2, 3, 1, 2, 3])
    
    XCTAssert(cycled.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = cycled.array()
    
  }
  
  func testLazyCycle() {
    
    var cycled = [1, 2].cycle()
    
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
    XCTAssert(cycled.next() == 1)
    XCTAssert(cycled.next() == 2)
  }
  
  // MARK: - HopJump
  
  // MARK: Eager
  
  func testHop() {
    
    let toHop = [1, 2, 3, 4, 5, 6]
    
    XCTAssert(toHop.hop(3) == [1, 4])
    XCTAssert(toHop.hop(2) == [1, 3, 5])
    XCTAssert(toHop.hop(1) == toHop)
    
  }

  
  // MARK: Lazy
  
  func testLazyHop() {
  
    let toHop = lazy([1, 2, 3, 4, 5, 6])
    
    XCTAssert(toHop.hop(3).elementsEqual([1, 4]))
    XCTAssert(toHop.hop(2).elementsEqual([1, 3, 5]))
    XCTAssert(toHop.hop(1).elementsEqual(toHop))
        
    let _ = toHop.hop(1).array()
    
  }
  
  // MARK: - Interpose
  
  // MARK: Eager
  
  func testInterposeSingle() {
    
    let interposed = [1, 2, 3].interpose(10)
    
    let expectation = [1, 10, 2, 10, 3]
    
    XCTAssert(interposed == expectation)
    
  }
  
  func testInterposeMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].interpose(10, n: 2)
    
    let expectation = [1, 2, 10, 3, 4, 10, 5]
    
    XCTAssert(interposed == expectation)
    
  }
  
  func testInterposeColSingle() {
    
    let interposed = [1, 2, 3].interpose([10, 20])
    
    let expectation = [1, 10, 20, 2, 10, 20, 3]
    
    XCTAssert(interposed == expectation)
    
  }
  
  func testInterposeColMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].interpose([10, 20], n: 2)
    
    let expectation = [1, 2, 10, 20, 3, 4, 10, 20, 5]
    
    XCTAssert(interposed == expectation)
    
  }
  
  func testInterdigitate() {
    
    let interdigged = interdig([1, 2, 3], [10, 20, 30])
    
    let expectation = [1, 10, 2, 20, 3, 30]
    
    XCTAssert(interdigged == expectation)
    
  }
  
  func testInterdigitateMultiple() {
    
    let interdigged = interdig([1, 2, 3, 4, 5], [10, 20, 30, 40, 50, 60], s0Len: 2, s1Len: 3)
    
    let expectation = [1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5]
    
    XCTAssert(interdigged == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyInterposeSingle() {
    
    let interposed = lazy([1, 2, 3]).interpose(10)
    
    let expectation = lazy([1, 10, 2, 10, 3, 10])
    
    XCTAssert(interposed.elementsEqual(expectation))
    
    let _ = interposed.array()
    
  }
  
  func testLazyInterposeMultiple() {
    
    let interposed = lazy([1, 2, 3, 4, 5]).interpose(10, n: 2)
    
    let expectation = lazy([1, 2, 10, 3, 4, 10, 5])
    
    XCTAssert(interposed.elementsEqual(expectation))
    
    let _ = interposed.array()

  }
  
  func testLazyInterposeColSingle() {
    
    let interposed = lazy([1, 2, 3]).interpose([10, 20])
    
    let expectation = [1, 10, 20, 2, 10, 20, 3, 10, 20]
    
    XCTAssert(interposed.elementsEqual(expectation))
    
    let _ = interposed.array()

  }
  
  func testLazyInterposeColMultiple() {
    
    let interposed = lazy([1, 2, 3, 4, 5]).interpose([10, 20], n: 2)
    
    let expectation = [1, 2, 10, 20, 3, 4, 10, 20, 5]
    
    XCTAssert(interposed.elementsEqual(expectation))
    
    let _ = interposed.array()

  }
  
  func testLazyInterdigitate() {
    
    let interdigged = interdig(lazy([1, 2, 3]), lazy([10, 20, 30]))
    
    let expectation = [1, 10, 2, 20, 3, 30]
    
    XCTAssert(interdigged.elementsEqual(expectation))
    
    let _ = interdigged.array()

  }
  
  func testLazyInterdigitateMultiple() {
    
    let interdigged = interdig(lazy([1, 2, 3, 4, 5]), lazy([10, 20, 30, 40, 50, 60]), s0Len: 2, s1Len: 3)
    
    let expectation = [1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5]
    
    XCTAssert(interdigged.elementsEqual(expectation))
    
    let _ = interdigged.array()

  }
  
  // MARK: - NestedSequences
  
  // MARK: Eager
  
  func testProdMethod() {
    
    let prod = [[1, 2], [3, 4]].product()
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssert(prod == expectation)
    
  }
  
  func testProdFunc() {
    
    let prod = product([1, 2], [3, 4])
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssert(prod == expectation)
    
  }
  
  func testTranspose() {
    
    let transposed = [
      [1, 2, 3],
      [1, 2, 3],
      [1, 2, 3]
      ].transpose()
    
    let expectation = [
      [1, 1, 1],
      [2, 2, 2],
      [3, 3, 3]
    ]
    
    XCTAssert(transposed == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyProdMethod() {
    
    let prod = [[1, 2], [3, 4]].lazyProduct()
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssert(prod.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = prod.array()

  }
  
  func testLazyProdFunc() {
    
    let prod = lazyProduct([1, 2], [3, 4])
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssert(prod.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = prod.array()

  }
  
  func testLazyTranspose() {
    
    let transposed = lazy([
      [1, 2, 3],
      [1, 2, 3],
      [1, 2, 3]
      ]).transpose()
    
    let expectation = [
      [1, 1, 1],
      [2, 2, 2],
      [3, 3, 3]
    ]
    
    XCTAssert(transposed.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = transposed.array()

  }
  
  // MARK: - Permutations
  
  // MARK: Eager
  
  func testLexPermsClosure() {
    
    let forward = [1, 2, 3].lexPermutations(<)
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward == fExpectation)
    
    let backward = [1, 2, 3].lexPermutations(>)
    
    let bExpectation = [[1, 2, 3]]
    
    XCTAssert(backward == bExpectation)
    
  }
  
  func testLexPerms() {
    
    let forward = [1, 2, 3].lexPermutations()
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward == fExpectation)
    
    let backward = [3, 2, 1].lexPermutations()
    
    let bExpectation = [[3, 2, 1]]
    
    XCTAssert(backward == bExpectation)
    
  }
  
  func testPermsInds() {
    
    let perms = [1, 2, 3].permutations()
    
    let expectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(perms == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyLexPermsClosure() {
    
    let forward = [1, 2, 3].lazyLexPermutations(<)
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward.elementsEqual(fExpectation, isEquivalent: ==))
    
    let backward = [1, 2, 3].lazyLexPermutations(>)
    
    let bExpectation = [[1, 2, 3]]
    
    XCTAssert(backward.elementsEqual(bExpectation, isEquivalent: ==))
    
    let _ = forward.array()
    let _ = backward.array()
    
  }
  
  func testLazyLexPerms() {
    
    let forward = [1, 2, 3].lazyLexPermutations()
    
    let fExpectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(forward.elementsEqual(fExpectation, isEquivalent: ==))
    
    let backward = [3, 2, 1].lazyLexPermutations()
    
    let bExpectation = [[3, 2, 1]]
    
    XCTAssert(backward.elementsEqual(bExpectation, isEquivalent: ==))
    
    let _ = forward.array()
    let _ = backward.array()
    
  }
  
  func testLazyPermsInds() {
    
    let perms = [1, 2, 3].lazyPermutations()
    
    let expectation = [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    
    XCTAssert(perms.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = perms.array()
    
  }
  
  // MARK: - ScanReduce
  
  // MARK: Eager
  
  func testReduce1() {
    
    let nums = [1, 2, 3, 4, 5]
    
    let optSum = nums.reduce(+)
    
    XCTAssert(optSum == 15)
    
  }
  
  func testScan() {
    
    let nums = [1, 2, 3, 4, 5]
    
    let scanSum = nums.scan(0, combine: +)
    
    let expectation = [1, 3, 6, 10, 15]
    
    XCTAssert(scanSum == expectation)
    
  }
  
  func testScan1() {
    
    let nums = [1, 2, 3, 4, 5]
    
    let scanSum = nums.scan(+)
    
    let expectation = [1, 3, 6, 10, 15]
    
    XCTAssert(scanSum == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyScan() {
    
    let nums = lazy([1, 2, 3, 4, 5])
    
    let scanSum = nums.scan(0, combine: +)
    
    let expectation = [1, 3, 6, 10, 15]
    
    XCTAssert(scanSum.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = scanSum.array()

  }
  
  func testLazyScan1() {
    
    let nums = lazy([1, 2, 3, 4, 5])
    
    let scanSum = nums.scan(+)
    
    let expectation = [1, 3, 6, 10, 15]
    
    XCTAssert(scanSum.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = scanSum.array()

  }
  
  // MARK: - TakeDrop
  
  // MARK: Eager
  
  func testTake() {
    
    let taken = [1, 2, 3, 4, 5, 6, 7].take(3)
    
    let expectation = [1, 2, 3]
    
    XCTAssert(taken == expectation)
    
  }
  
  func testDrop() {
    
    let dropped = [1, 2, 3, 4, 5, 6, 7].drop(3)
    
    let expectation = [4, 5, 6, 7]
    
    XCTAssert(dropped == expectation)
    
  }
  
  func testTakeWhile() {
    
    let taken = [1, 2, 3, 4, 5, 1, 2, 3].takeWhile { $0 < 5 }
    
    let expectation = [1, 2, 3, 4]
    
    XCTAssert(taken == expectation)
    
  }
  
  func testDropwhile() {
    
    let dropped = [1, 2, 3, 4, 5, 1, 2, 3].dropWhile { $0 < 5 }
    
    let expectation = [5, 1, 2, 3]
    
    XCTAssert(dropped == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyTake() {
    
    let taken = lazy([1, 2, 3, 4, 5, 6, 7]).take(3)
    
    let expectation = [1, 2, 3]
    
    XCTAssert(taken.elementsEqual(expectation))
    
    let _ = taken.array()

  }
  
  func testLazyDrop() {
    
    let dropped = lazy([1, 2, 3, 4, 5, 6, 7]).drop(3)
    
    let expectation = [4, 5, 6, 7]
    
    XCTAssert(dropped.elementsEqual(expectation))
    
    let _ = dropped.array()

  }
  
  func testLazyTakeWhile() {
    
    let taken = lazy([1, 2, 3, 4, 5, 1, 2, 3]).takeWhile { $0 < 5 }
    
    let expectation = [1, 2, 3, 4]
    
    XCTAssert(taken.elementsEqual(expectation))
    
    let _ = taken.array()

  }
  
  func testLazyDropwhile() {
    
    let dropped = lazy([1, 2, 3, 4, 5, 1, 2, 3]).dropWhile { $0 < 5 }
    
    let expectation = [5, 1, 2, 3]
    
    XCTAssert(dropped.elementsEqual(expectation))
    
    let _ = dropped.array()

  }
  
  // MARK: - Zip
  
  func testWithNilPadding() {
    
    let zipped = zipWithPadding([1, 2, 3], [1, 2])
    
    let expectation: Array<(Int?, Int?)> = [ (1, 1), (2, 2), (3, nil) ]
    
    XCTAssert(zipped.elementsEqual(
      expectation,
      isEquivalent: { $0.0 == $1.0 && $0.1 == $1.1 }
      )
    )
    
    let _ = zipped.array()
    
  }
  
  func testZipWithCustomPadding() {
    
    let zipped = zipWithPadding([1, 2, 3], [1, 2], pad0: 10, pad1: 20)
    
    let expectation = [(1, 1), (2, 2), (3, 20)]
    
    XCTAssert(zipped.elementsEqual(
      expectation,
      isEquivalent: { $0.0 == $1.0 && $0.1 == $1.1 }
      )
    )
    
    let _ = zipped.array()

  }
  
  // MARK: - List
  // MARK: Initialising
  
  func testLaziness(list: LazyList<Int>) {
    var i = 3628376
    let s = anyGenerator { i == 3628386 ? nil : i++ }
    for num in list.extended(s) {
      if (3628376..<3628386).contains(num) {
        XCTAssert(i == num + 1)
      } else {
        XCTAssert(i == 3628376)
      }
    }
  }
  
  func testListInit() {
    
    let result: List = [1, 2, 3, 4, 5]
    
    XCTAssert(result is List<Int>)
    
    let expectation = [1, 2, 3, 4, 5]
    
    XCTAssert(result.elementsEqual(expectation))
    
  }

  func testLazyListInit() {
    
    let result: LazyList = [1, 2, 3, 4, 5]
    
    testLaziness(result)
    
    let expectation = [1, 2, 3, 4, 5]
    
    XCTAssert(result.elementsEqual(expectation))
    
  }
  
  func testListChunk() {
    
    let toChunk: List = [1, 2, 3, 4, 5, 6, 7]
    
    let result = toChunk.chunk(3)
    
    XCTAssert(result is List<List<Int>>)
    
    let expectation: [List<Int>] = [[1, 2, 3], [4, 5, 6], [7]]
    
    result.elementsEqual(expectation) {$0.elementsEqual($1)}
  
  }
  
  func testLazyListChunk() {
    
    let toChunk: LazyList = [1, 2, 3, 4, 5, 6, 7]
    
    let result = toChunk.chunk(3)
    
    XCTAssert(result is LazyList<LazyList<Int>>)
    
    let tResult = result
    
    for list in tResult {
      testLaziness(list)
    }
    
    let expectation: [LazyList<Int>] = [[1, 2, 3], [4, 5, 6], [7]]
    
    result.elementsEqual(expectation) {$0.elementsEqual($1)}
    
  }
  
}
