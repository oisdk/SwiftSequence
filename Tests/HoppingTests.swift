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
  
  var allTests: [(String, () -> ())] {
    return [
      ("testHop", testHop),
      ("testLongHop", testLongHop),
      ("testSliceThenHop", testSliceThenHop)
    ]
  }
  
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
          let (a,b,c) = (ar[i..., by: h],ar[...i, by: h],ar[..<i, by: h])
          XCTAssertEqualSeq(a, ar[i...].refHop(h))
          XCTAssertEqualSeq(b, ar[...i].refHop(h))
          XCTAssertEqualSeq(c, ar[..<i].refHop(h))
          for (ja, jr) in zip(a.indices, 0...) {
            for (ka, kr) in zip((ja..<a.endIndex), jr...) {
              XCTAssertEqualSeq(a[ja..<ka], Array(a)[jr..<kr])
            }
          }
          for (jb, jr) in zip(b.indices, 0...) {
            for (kb, kr) in zip((jb..<b.endIndex), jr...) {
              XCTAssertEqualSeq(b[jb..<kb], Array(b)[jr..<kr])
            }
          }
          for (jc, jr) in zip(c.indices, 0...) {
            for (kc, kr) in zip((jc..<c.endIndex), jr...) {
              XCTAssertEqualSeq(c[jc..<kc], Array(c)[jr..<kr])
            }
          }
        }
      }
    }
  }
}