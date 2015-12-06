import XCTest
import SwiftSequence

class SlicingTests: XCTestCase {
  
  func testHop() {
    
    for ar in (0..<20).map(Array<Int>.init) {
      XCTAssertEqualSeq(ar, ar[by: 1])
    }
  }
  
  func testLongHop() {
    for ar in (0..<20).map(Array<Int>.init) {
      for i in (1..<20) {
        let expect = ar
          .startIndex
          .stride(to: ar.endIndex, by: i)
          .map { n in ar[n] }
        let real = ar[by: i]
        XCTAssertEqualSeq(real, expect)
      }
    }
  }
}