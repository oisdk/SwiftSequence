import XCTest
import SwiftSequence

class LazyPrefixTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testLazyPrefix", testLazyPrefix),
    ]
  }
  
  func testLazyPrefix() {
    let prefixed = [1, 2, 3, 4, 5, 6, 7, 8].lazy.filter { $0 > 2 }.lazyPrefix(2)
    let expectation = [3, 4]
    XCTAssertEqualSeq(prefixed, expectation)
  }

}