import XCTest
@testable import SwiftSequence

class HopJumpTests: XCTestCase {
  
  func testEndless() {
    
    for _ in 0..<1000 {
      let n = arc4random_uniform(30)
      let s = n...
      XCTAssertEqual(n, s.first { _ in true })
      var i = n
      for (x,_) in zip(s, 0..<10) {
        XCTAssertEqual(x,i)
        i += 1
      }
    }
  }
  
  func testSwitches() {
    
    for _ in 0..<1000 {
      let n = arc4random_uniform(15)
      let i = arc4random_uniform(30)
      
      switch i {
      case n...: XCTAssert(i >= n)
      default  : XCTAssert(i < n)
      }
      switch i {
      case ..<n: XCTAssert(i < n)
      default  : XCTAssert(i >= n)
      }
      switch i {
      case ...n: XCTAssert(i <= n)
      default  : XCTAssert(i > n)
      }

      let nd = Double(n)
      let id = Double(i)
      switch id {
      case nd...: XCTAssert(id >= nd)
      default   : XCTAssert(id < nd)
      }
      switch id {
      case ..<nd: XCTAssert(id < nd)
      default   : XCTAssert(id >= nd)
      }
      switch id {
      case ...nd: XCTAssert(id <= nd)
      default   : XCTAssert(id > nd)
      }
    }
  }
  
  
  func testSubScriptGet() {
    
    let chars = Array("abcdefghijklmnopqrstuvwxyz".characters)
    let randChar: () -> Character = { () in
      chars[Int(arc4random_uniform(26))]
    }
    
    for _ in 0..<1000 {
      
      let str = String((0..<(arc4random_uniform(20)+2)).map { _ in randChar() }).characters
      
      let inds = Array(str.indices)
      let i = inds[Int(arc4random_uniform(UInt32(inds.count-1)))]
      XCTAssertEqual(String(str[i...]), String(str.suffixFrom(i)))
      XCTAssertEqual(String(str[...i]), String(str.prefixThrough(i)))
      XCTAssertEqual(String(str[..<i]), String(str.prefixUpTo(i)))
      
    }
    
  }
  
  func testSubScriptSet() {
    
    for _ in 0..<1000 {
      
      let ar = Array<Int>(randLength: 20)
      
      let i = Int.randLim(ar.count-1)
      
      XCTAssertEqual(ar.suffixFrom(i), ar[i...])
      XCTAssertEqual(ar.prefixUpTo(i), ar[..<i])
      XCTAssertEqual(ar.prefixThrough(i), ar[...i])
      
      var a = ar
      let randa = Array<Int>(randLength: ar.count - i)
      a[i...] = ArraySlice(randa)
      XCTAssertEqual(ar[..<i] + randa, a)
      
      var b = ar
      let randb = Array<Int>(randLength: i)
      b[..<i] = ArraySlice(randb)
      XCTAssertEqual(randb + ar[i...], b)
      
      var c = ar
      let randc = Array<Int>(randLength: i+1)
      c[...i] = ArraySlice(randc)
      XCTAssertEqual(randc + ar[i.successor()...], c)
      
    }
  }
}