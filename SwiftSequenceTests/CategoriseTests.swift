import XCTest
import Foundation
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
  
  // MARK: Lazy
  
  func testLazyUniques() {
    
    let uniqueSeq = [1, 1, 1, 3, 3, 2, 4, 3].lazy.uniques()
    
    let expectation = [1, 3, 2, 4].lazy
    
    XCTAssert(uniqueSeq.elementsEqual(expectation))
    
  }
  
  func testLazyGroup() {
    
    let groupSeq = [1, 2, 2, 3, 1, 1, 3, 4, 2].lazy.group()
    
    let expectation = [[1], [2, 2], [3], [1, 1], [3], [4], [2]].lazy
    
    XCTAssert(
      !zip(groupSeq, expectation).contains {
        a, b in
        a != b
      }
    )
  }
  
  func testLazyGroupClos() {
    
    let groupSeq = [1, 3, 5, 20, 22, 18, 6, 7].lazy.group { abs($0 - $1) < 5 }
    
    let expectation = [[1, 3, 5], [20, 22, 18], [6, 7]].lazy
    
    XCTAssert(
      !zip(groupSeq, expectation).contains {
        a, b in
        a != b
      }
    )
  }
  
  func testMostFrequent() {
    
    
    let nums = (1...100).map { _ in Int(arc4random_uniform(10)) }
    
    let mostFreq = nums.mostFrequent()!
    
    let freqs = nums.freqs()
    
    let occurances = freqs[mostFreq]
    
    XCTAssert(!freqs.values.contains { $0 > occurances})
    
    
  }
}