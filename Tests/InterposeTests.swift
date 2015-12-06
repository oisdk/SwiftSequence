import XCTest
import SwiftSequence

class InterposeTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testInterposeSingle", testInterposeSingle),
      ("testInterposeMultiple", testInterposeMultiple),
      ("testInterposeColSingle", testInterposeColSingle),
      ("testInterposeColMultiple", testInterposeColMultiple),
      ("testInterdigitate", testInterdigitate),
      ("testInterdigitateMultiple", testInterdigitateMultiple),
      ("testLazyInterposeSingle", testLazyInterposeSingle),
      ("testLazyInterposeMultiple", testLazyInterposeMultiple),
      ("testLazyInterposeColSingle", testLazyInterposeColSingle),
      ("testLazyInterposeColMultiple", testLazyInterposeColMultiple),
      ("testLazyInterdigitate", testLazyInterdigitate),
      ("testLazyInterdigitateMultiple", testLazyInterdigitateMultiple)
    ]
  }
  
  // MARK: Eager
  
  func testInterposeSingle() {
    
    let interposed = [1, 2, 3].interpose(10)
    
    let expectation = [1, 10, 2, 10, 3]
    
    XCTAssertEqual(interposed, expectation)
    
  }
  
  func testInterposeMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].interpose(10, n: 2)
    
    let expectation = [1, 2, 10, 3, 4, 10, 5]
    
    XCTAssertEqual(interposed, expectation)
    
  }
  
  func testInterposeColSingle() {
    
    let interposed = [1, 2, 3].interpose([10, 20])
    
    let expectation = [1, 10, 20, 2, 10, 20, 3]
    
    XCTAssertEqual(interposed, expectation)
    
  }
  
  func testInterposeColMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].interpose([10, 20], n: 2)
    
    let expectation = [1, 2, 10, 20, 3, 4, 10, 20, 5]
    
    XCTAssertEqual(interposed, expectation)
    
  }
  
  func testInterdigitate() {
    
    let interdigged = interdig([1, 2, 3], [10, 20, 30])
    
    let expectation = [1, 10, 2, 20, 3, 30]
    
    XCTAssertEqual(interdigged, expectation)
    
  }
  
  func testInterdigitateMultiple() {
    
    let interdigged = interdig([1, 2, 3, 4, 5], [10, 20, 30, 40, 50, 60], s0Len: 2, s1Len: 3)
    
    let expectation = [1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5]
    
    XCTAssertEqual(interdigged, expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyInterposeSingle() {
    
    let interposed = [1, 2, 3].lazy.interpose(10)
    
    let expectation = [1, 10, 2, 10, 3, 10].lazy
    
    XCTAssertEqualSeq(interposed, expectation)
    
  }
  
  func testLazyInterposeMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].lazy.interpose(10, n: 2)
    
    let expectation = [1, 2, 10, 3, 4, 10, 5].lazy
    
    XCTAssertEqualSeq(interposed, expectation)
    
  }
  
  func testLazyInterposeColSingle() {
    
    let interposed = [1, 2, 3].lazy.interpose([10, 20])
    
    let expectation = [1, 10, 20, 2, 10, 20, 3, 10, 20]
    
    XCTAssertEqualSeq(interposed, expectation)
    
  }
  
  func testLazyInterposeColMultiple() {
    
    let interposed = [1, 2, 3, 4, 5].lazy.interpose([10, 20], n: 2)
    
    let expectation = [1, 2, 10, 20, 3, 4, 10, 20, 5]
    
    XCTAssertEqualSeq(interposed, expectation)
    
  }
  
  func testLazyInterdigitate() {
    
    let interdigged = interdig([1, 2, 3].lazy, [10, 20, 30].lazy)
    
    let expectation = [1, 10, 2, 20, 3, 30]
    
    XCTAssertEqualSeq(interdigged, expectation)
    
  }
  
  func testLazyInterdigitateMultiple() {
    
    let interdigged = interdig([1, 2, 3, 4, 5].lazy, [10, 20, 30, 40, 50, 60].lazy, s0Len: 2, s1Len: 3)
    
    let expectation = [1, 2, 10, 20, 30, 3, 4, 40, 50, 60, 5]
    
    XCTAssertEqualSeq(interdigged, expectation)
    
  }
}