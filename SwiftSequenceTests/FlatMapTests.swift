import XCTest
@testable import SwiftSequence

class FlatMapTests: XCTestCase {
  
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

}