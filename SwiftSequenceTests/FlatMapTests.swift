import XCTest
@testable import SwiftSequence

class FlatMapTests: XCTestCase {
  
  func testFlatMapSeq() {
    
    let seq = [1, 2, 3, 4, 5].lazy
    
    let flattened = seq.flatMap { [$0, 10] }
    
    let expectation = [1, 10, 2, 10, 3, 10, 4, 10, 5, 10]
    
    XCTAssertEqual(flattened)(expectation)
    
  }
  
  func testFlatMapOpt() {
    
    let seq = [1, 2, 3, 4, 5].lazy
    
    let flattened = seq.flatMap { $0 % 2 == 0 ? $0 / 2 : nil }
    
    let expectation = [1, 2]
    
    XCTAssertEqual(flattened)(expectation)
    
  }

}