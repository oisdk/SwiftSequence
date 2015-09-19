import XCTest
@testable import SwiftSequence

class HopJumpTests: XCTestCase {
  
  // MARK: Eager
  
  func testHop() {
    
    for randAr in (1..<10).map(Array<Int>.init) {
      
      let hop = Int.randLim(randAr.count - 1) + 1
      
      let expectation = randAr
        .indices
        .filter { n in n % hop == 0 }
        .map { i in randAr[i] }
      
      let reality = AnySequence(randAr).hop(hop)
      let intReality = randAr.hop(hop)
      
      XCTAssert(expectation == reality)
      XCTAssert(expectation == intReality)
      
    }
    
  }
  
  // MARK: Lazy
  
  func testLazyHop() {
    
    for randAr in (1..<10).map(Array<Int>.init) {
      
      let hop = Int.randLim(randAr.count - 1) + 1
      
      let expectation = randAr.hop(hop)
      
      let randReality = randAr.lazy.hop(hop)
      let reality = AnySequence(randAr).lazy.hop(hop)
      
      XCTAssert(expectation.elementsEqual(reality))
      XCTAssert(expectation.elementsEqual(randReality))
      
    }
    
  }
}