import XCTest
import SwiftSequence

class ScanReduceTests: XCTestCase {
  
  var allTests : [(String, () -> ())] {
    return [
      ("testReduce1", testReduce1),
      ("testScan", testScan),
      ("testScan1", testScan1),
      ("testLazyScan", testLazyScan),
      ("testLazyScan1", testLazyScan1)
    ]
  }
  
  // MARK: Eager
  
  func testReduce1() {

    let nums = WatcherSequence([1, 2, 3, 4, 5])
    
    let optSum = nums.reduce(+)
    
    let _ = optSum.map { t in XCTAssertEqual(15, t) }
    
  }
  
  func testScan() {
    
    let nums = WatcherSequence([1, 2, 3, 4, 5])
    
    let scanSum = nums.scan(0, combine: +)
    
    let expectation = [1, 3, 6, 10, 15]
    
    XCTAssertEqual(scanSum, expectation)
    
  }
  
  func testScan1() {
    
    let nums = WatcherSequence([1, 2, 3, 4, 5])
    
    let scanSum = nums.scan(+)
    
    let expectation = [3, 6, 10, 15]
    
    XCTAssertEqual(scanSum, expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyScan() {
    
    let nums = WatcherSequence([1, 2, 3, 4, 5]).lazy
    
    let scanSum = nums.scan(0, combine: +)
    
    let expectation = [1, 3, 6, 10, 15]
    
    XCTAssertEqualSeq(scanSum, expectation)
    
  }
  
  func testLazyScan1() {
    
    let nums = WatcherSequence([1, 2, 3, 4, 5]).lazy
    
    let scanSum = nums.scan(+)
    
    let expectation = [3, 6, 10, 15]
    
    XCTAssertEqualSeq(scanSum, expectation)
    
  }
}