import XCTest
@testable import SwiftSequence
import Foundation

class CombinationsTests: XCTestCase {
  // MARK: Eager
  
  func testCombosWithoutRep() {
    
    let comboed = [1, 2, 3].combos(2)
    
    let expectation = [[1, 2], [1, 3], [2, 3]]
    
    XCTAssertEqual(comboed)(expectation)
    
  }
  
  func testCombosWithRep() {
    
    let comboed = [1, 2, 3].combosWithRep(2)
    
    let expectation = [[1, 1], [1, 2], [1, 3], [2, 2], [2, 3], [3, 3]]
    
    XCTAssertEqual(comboed)(expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyCombosWithoutRep() {
    
    for randAr in (0..<10).map(Array<Int>.init) {
      
      let eager = randAr.combos(min(randAr.count, 3))
      
      let lazy = randAr.lazyCombos(min(randAr.count, 3))
      
      XCTAssertEqual(eager)(lazy)
      
    }
    
  }
  
  func testLazyCombosWithRep() {
    
    for randAr in(0..<10).map(Array<Int>.init) {
      
      let eager = randAr.combosWithRep(min(randAr.count, 3))
      
      let lazy = randAr.lazyCombosWithRep(min(randAr.count, 3))
      
      XCTAssertEqual(eager)(lazy)
      
    }
    
  }
  
  
}