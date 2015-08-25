import XCTest
@testable import SwiftSequence

class ScanReduceTests: XCTestCase {
  
  // MARK: Eager
  
  func testReduce1() {
    
    let nums = [1, 2, 3, 4, 5]
    
    let optSum = nums.reduce(+)
    
    XCTAssert(optSum == 15)
    
  }
  
  func testScan() {
    
    let nums = [1, 2, 3, 4, 5]
    
    let scanSum = nums.scan(0, combine: +)
    
    let expectation = [1, 3, 6, 10, 15]
    
    XCTAssert(scanSum == expectation)
    
  }
  
  func testScan1() {
    
    let nums = [1, 2, 3, 4, 5]
    
    let scanSum = nums.scan(+)
    
    let expectation = [3, 6, 10, 15]
    
    XCTAssert(scanSum == expectation)
    
  }
  
  // MARK: Lazy
  
  func testLazyScan() {
    
    let nums = [1, 2, 3, 4, 5].lazy
    
    let scanSum = nums.scan(0, combine: +)
    
    let expectation = [1, 3, 6, 10, 15]
    
    XCTAssert(scanSum.elementsEqual(expectation, isEquivalent: ==))
    
  }
  
  func testLazyScan1() {
    
    let nums = [1, 2, 3, 4, 5].lazy
    
    let scanSum = nums.scan(+)
    
    let expectation = [3, 6, 10, 15]
    
    XCTAssert(scanSum.elementsEqual(expectation, isEquivalent: ==))
    
  }
}