import Foundation
import XCTest
@testable import SwiftSequence

class ContiguousListTests: XCTestCase {
  
  func testIndex() {
    
    let x = ContiguousListIndex(Int(arc4random_uniform(10000)))
    
    XCTAssert(x.distanceTo(x.successor()) == 1)
    
    XCTAssert(x.distanceTo(x.predecessor()) == -1)
    
    let y = ContiguousListIndex(Int(arc4random_uniform(10000)))
    
    XCTAssert(x.advancedBy(x.distanceTo(y)) == y)
    
    XCTAssert(x == x)
    
    XCTAssert(x.successor() > x)
    
    XCTAssert(x.predecessor() < x)
    
    XCTAssert(x.advancedBy(0) == x)
    
    XCTAssert(x.advancedBy(1) == x.successor())
    
    XCTAssert(x.advancedBy(-1) == x.predecessor())
    
    let m = Int(arc4random_uniform(10000))
    
    XCTAssert(x.distanceTo(x.advancedBy(m)) == m)
    
  }
  
  func testIndexing() {
    
    let expectation = [1, 2, 3, 4, 5]
    
    let reality = ContiguousList(expectation)
    
    XCTAssert(expectation[expectation.endIndex.predecessor()] == reality[reality.endIndex.predecessor()])
    
    XCTAssert(expectation[expectation.startIndex] == reality[reality.startIndex])
    
    XCTAssert(expectation.count == reality.count)
    
  }
  
  func testIndexGetting() {
    
    let expectation = [Int](0...100)
    
    let reality = ContiguousList(expectation)
    
    for i in expectation.indices {
      XCTAssert(expectation[i] == reality[i])
    }
    
  }
  
  func testIndexSetting() {
    
    let array = [Int](0...10)
    
    let list = ContiguousList(array)
    
    for i in array.indices {
      
      var (expectation, reality) = (array, list)
      
      let n = Int(arc4random_uniform(10000))
      
      expectation[i] = n
      
      reality[i] = n
      
      XCTAssert(expectation.elementsEqual(reality))
    }
  }
  
  func testArrayLiteralConvertible() {
    
    let expectation = [1, 2, 3, 4, 5]
    
    let reality: ContiguousList = [1, 2, 3, 4, 5]
    
    XCTAssert(expectation.elementsEqual(reality))
    
  }
  
}