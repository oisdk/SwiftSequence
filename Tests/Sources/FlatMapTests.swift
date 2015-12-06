import XCTest
import SwiftSequence

class FlatMapTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testFlatMapOpt", testFlatMapOpt)
    ]
  }
  
  func testFlatMapOpt() {
    
    let seq = [1, 2, 3, 4, 5].lazy
    
    let flattened = seq.flatMap { $0 % 2 == 0 ? $0 / 2 : nil }
    
    let expectation = [1, 2]
    
    XCTAssertEqualSeq(flattened, expectation)
    
  }

}