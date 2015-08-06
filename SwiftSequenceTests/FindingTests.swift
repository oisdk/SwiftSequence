import XCTest
@testable import SwiftSequence

class FindingTests: XCTestCase {
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
}