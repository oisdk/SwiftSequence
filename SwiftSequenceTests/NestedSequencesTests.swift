import XCTest
@testable import SwiftSequence

class NestedSequencesTests: XCTestCase {
  
  // MARK: Eager
  
  func testProdMethod() {
    
    let prod = [[1, 2], [3, 4]].product()
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssertEqual(prod)(expectation)
    
  }
  
  func testProdFunc() {
    
    let prod = product([1, 2], [3, 4])
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssertEqual(prod)(expectation)
    
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
    
    XCTAssertEqual(transposed)(expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyProdMethod() {
    
    let prod = [[1, 2], [3, 4]].lazyProduct()
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssertEqual(prod)(expectation)
    
  }
  
  func testLazyProdFunc() {
    
    let prod = lazyProduct([1, 2], [3, 4])
    
    let expectation = [[1, 3], [1, 4], [2, 3], [2, 4]]
    
    XCTAssertEqual(prod)(expectation)
    
    
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
    
    XCTAssertEqual(transposed)(expectation)
    
  }
}