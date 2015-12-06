import XCTest
import SwiftSequence

extension CollectionType where Index: RandomAccessIndexType {
  private func refHop(by: Index.Stride) -> [Generator.Element] {
    return startIndex
      .stride(to: endIndex, by: by)
      .map { n in self[n] }
  }
}

class SlicingTests: XCTestCase {
  
  func testHop() {
    
    for ar in (0..<20).map(Array<Int>.init) {
      XCTAssertEqualSeq(ar, ar[by: 1])
    }
  }
  
  func testLongHop() {
    for ar in (0..<20).map(Array<Int>.init) {
      for i in (1..<20) {
        let expect = ar.refHop(i)
        let real = ar[by: i]
        XCTAssertEqualSeq(real, expect)
      }
    }
  }
  
  func testSliceThenHop() {
    for ar in (0..<20).map(Array<Int>.init) {
      for h in ar.indices.dropFirst() {
        for i in ar.indices {
          XCTAssertEqualSeq(ar[i..., by: h], ar[i...].refHop(h))
          XCTAssertEqualSeq(ar[...i, by: h], ar[...i].refHop(h))
          XCTAssertEqualSeq(ar[..<i, by: h], ar[..<i].refHop(h))
        }
      }
    }
  }
}