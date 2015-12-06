import XCTest
import SwiftSequence

class NestedSequencesTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testProdMethod", testProdMethod),
      ("testProdFunc", testProdFunc),
      ("testTranspose", testTranspose),
      ("testLazyProdMethod", testLazyProdMethod),
      ("testLazyProdFunc", testLazyProdFunc),
      ("testLazyTranspose", testLazyTranspose)
    ]
  }
  
  // MARK: Eager
  
  func testProdMethod() {
    
    let prod = [[1, 2], [3, 4]].product()
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssertEqualNested(prod, expectation)
    
  }
  
  func testProdFunc() {
    
    let prod = product([1, 2], [3, 4])
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssertEqualNested(prod, expectation)
    
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
    
    XCTAssertEqualNested(transposed, expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyProdMethod() {
    
    
    let randAr = (0...10).map({ _ in Int.randLim(5) + 1 }).map(Array<Character>.init)
    
    let prodToCount = randAr.lazyProduct()
    
    XCTAssertEqual(prodToCount.underestimateCount(), Array(prodToCount).count)
    
    let prod = [[1, 2], [3, 4]].lazyProduct()
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssertEqualNested(prod, expectation)
    
  }
  
  func testLazyProdFunc() {
    
    let prod = lazyProduct([1, 2], [3, 4])
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssertEqualNested(prod, expectation)
    
    
  }
  
  func testLazyTranspose() {
    
    let transposed = [
      [1, 2, 3],
      [1, 2, 3],
      [1, 2, 3]
      ].lazy.transpose()
    
    let expectation = [
      [1, 1, 1],
      [2, 2, 2],
      [3, 3, 3]
    ]
    
    XCTAssertEqualNested(transposed, expectation)
    
  }
}