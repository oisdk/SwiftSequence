import XCTest
@testable import SwiftSequence

class CombinationsTests: XCTestCase {
  // MARK: Eager
  
  func testCombosWithoutRep() {
    
    let comboed = [1, 2, 3].combos(2)
    
    let expectation = [[1, 2], [1, 3], [2, 3]]
    
    XCTAssert(comboed == expectation)
    
  }
  
  func testCombosWithRep() {
    
    let comboed = [1, 2, 3].combosWithRep(2)
    
    let expectation = [[1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]]
    
    XCTAssert(comboed == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyCombosWithoutRep() {
    
    let comboed = [1, 2, 3].lazyCombos(2)
    
    let expectation = lazy([[1, 2], [1, 3], [2, 3]])
    
    XCTAssert(comboed.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = comboed.array()
    
  }
  
  func testLazyCombosWithRep() {
    
    let comboed = [1, 2, 3].lazyCombosWithRep(2)
    
    let expectation = lazy([[1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]])
    
    XCTAssert(comboed.elementsEqual(expectation, isEquivalent: ==))
    
    let _ = comboed.array()
    
  }
}