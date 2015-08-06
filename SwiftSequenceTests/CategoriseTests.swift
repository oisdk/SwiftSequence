import XCTest
@testable import SwiftSequence

class CategoriseTests: XCTestCase {
  
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
}