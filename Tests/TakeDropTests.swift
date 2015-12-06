import XCTest
@testable import SwiftSequence

class TakeDropTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testTakeWhile", testTakeWhile),
      ("testDropwhile", testDropwhile),
      ("testLazyTakeWhile", testLazyTakeWhile),
      ("testLazyDropwhile", testLazyDropwhile),
      ("testBreak", testBreak),
      ("testBreakPred", testBreakPred),
    ]
  }
  
  // MARK: Eager
  
  func testTakeWhile() {
    
    let taken = [1, 2, 3, 4, 5, 1, 2, 3].prefixWhile { $0 < 5 }
    let expectation = [1, 2, 3, 4]
    XCTAssertEqual(taken, expectation)
  }
  
  func testDropwhile() {
    
    let dropped = [1, 2, 3, 4, 5, 1, 2, 3].dropWhile { $0 < 5 }
    let expectation = [5, 1, 2, 3]
    XCTAssertEqual(dropped, expectation)
  }
  
  // MARK: Lazy
  
  func testLazyTakeWhile() {
    
    let taken = [1, 2, 3, 4, 5, 1, 2, 3].lazy.prefixWhile { $0 < 5 }
    let expectation = [1, 2, 3, 4]
    XCTAssertEqualSeq(taken, expectation)
  }
  
  func testLazyDropwhile() {
    
    let dropped = [1, 2, 3, 4, 5, 1, 2, 3].lazy.dropWhile { $0 < 5 }
    let expectation = [5, 1, 2, 3]
    XCTAssertEqualSeq(dropped, expectation)
  }
  
  func testBreak() {
    
    for randAr in (0...10).map(Array<Int>.init) {
      
      let n = Int.randLim(randAr.count)
      
      let (f,b) = randAr.breakAt(n)
      
      XCTAssertEqual(f.count, n)
      XCTAssertEqual(b.count, randAr.count - n)
      XCTAssertEqualSeq(f + b, randAr)
      
      let (af,ab) = AnySequence(randAr).breakAt(n)
      XCTAssertEqualSeq(af, f)
      XCTAssertEqualSeq(ab, b)
    }
  }
  
  func testBreakPred() {
    for randAr in (0...10).map(Array<Int>.init) {
      
      let p = randPred()
      
      let (f,b) = randAr.breakAt(p)
      
      XCTAssertFalse(f.contains(p))
      XCTAssert(b.first.map(p) ?? true)
      XCTAssertEqualSeq(f + b, randAr)
      
      let (af,ab) = AnySequence(randAr).breakAt(p)
      
      XCTAssertEqualSeq(af, f)
      XCTAssertEqualSeq(ab, b)
    }
  }
  
}