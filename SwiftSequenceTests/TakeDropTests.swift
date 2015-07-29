import XCTest

class TakeDropTests: XCTestCase {
  
  // MARK: Eager
  
  func testTake() {
    
    let taken = [1, 2, 3, 4, 5, 6, 7].take(3)
    
    let expectation = [1, 2, 3]
    
    XCTAssert(taken == expectation)
    
  }
  
  func testDrop() {
    
    let dropped = [1, 2, 3, 4, 5, 6, 7].drop(3)
    
    let expectation = [4, 5, 6, 7]
    
    XCTAssert(dropped == expectation)
    
  }
  
  func testTakeWhile() {
    
    let taken = [1, 2, 3, 4, 5, 1, 2, 3].takeWhile { $0 < 5 }
    
    let expectation = [1, 2, 3, 4]
    
    XCTAssert(taken == expectation)
    
  }
  
  func testDropwhile() {
    
    let dropped = [1, 2, 3, 4, 5, 1, 2, 3].dropWhile { $0 < 5 }
    
    let expectation = [5, 1, 2, 3]
    
    XCTAssert(dropped == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyTake() {
    
    let taken = lazy([1, 2, 3, 4, 5, 6, 7]).take(3)
    
    let expectation = [1, 2, 3]
    
    XCTAssert(taken.elementsEqual(expectation))
    
    let _ = taken.array()
    
  }
  
  func testLazyDrop() {
    
    let dropped = lazy([1, 2, 3, 4, 5, 6, 7]).drop(3)
    
    let expectation = [4, 5, 6, 7]
    
    XCTAssert(dropped.elementsEqual(expectation))
    
    let _ = dropped.array()
    
  }
  
  func testLazyTakeWhile() {
    
    let taken = lazy([1, 2, 3, 4, 5, 1, 2, 3]).takeWhile { $0 < 5 }
    
    let expectation = [1, 2, 3, 4]
    
    XCTAssert(taken.elementsEqual(expectation))
    
    let _ = taken.array()
    
  }
  
  func testLazyDropwhile() {
    
    let dropped = lazy([1, 2, 3, 4, 5, 1, 2, 3]).dropWhile { $0 < 5 }
    
    let expectation = [5, 1, 2, 3]
    
    XCTAssert(dropped.elementsEqual(expectation))
    
    let _ = dropped.array()
    
  }
}