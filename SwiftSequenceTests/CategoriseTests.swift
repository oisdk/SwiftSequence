import XCTest
import Foundation
@testable import SwiftSequence

class CategoriseTests: XCTestCase {
  
  // MARK: Eager
  
  func testCat() {
    
    for randAr in (1...10).map(Array<Int>.init) {
      let n = Int.randLim(10) + 1
      let keyFunc = { i in i % n + 1 }
      let reality = randAr.categorise(keyFunc)
      for (k,v) in reality {
        v.map(keyFunc).forEach(XCTAssertEqual(k))
      }
    }
  }
  
  func testFreqs() {
    
    for _ in 0...10 {
      
      let randAr = (1...100).map { _ in Int.randLim(20) }
      
      for (k,v) in randAr.freqs() {
        
        XCTAssertEqual(randAr.count { e in e == k }, v)
        
      }
      
    }
    
  }
  
  func testUniques() {
    
    for _ in 0...10 {
      
      let randAr = (1...100).map { _ in Int.randLim(20) }
      
      XCTAssertEqual(randAr.uniques().count, Set(randAr).count)
    }
    
  }
  
  // MARK: Lazy
  
  func testLazyUniques() {
    
    for _ in 1...10 {
      
      let randAr = (1...100).map { _ in Int.randLim(20) }
      
      XCTAssertEqual(randAr.lazy.uniques())(randAr.uniques())
      
    }
    
  }
  
  func testLazyGroup() {
    
    for _ in 1...10 {
      
      let randAr = (1...100).map { _ in Int.randLim(20) }
      
      let lazyGroup = randAr.lazy.group()
      
      XCTAssertFalse(lazyGroup.map(Set.init).contains { s in s.count != 1 })
      
      let ar = Array(lazyGroup)
      
      XCTAssertFalse(ar.dropFirst().enumerate().contains { (i,v) in ar[i].last == v.first })
      
    }
  }
  
  func testLazyGroupClos() {
    
    for _ in 1...10 {
      
      let randAr = (1...100).map { _ in Int.randLim(20) }
    
      let n = Int.randLim(10)
    
      let isEq = { (a,b) in abs(a - b) < n }
      
      let lGroup = randAr.lazy.group(isEq)
      
      for a in lGroup {
      
        
        XCTAssertFalse(a.dropFirst().enumerate().contains { (i,v) in !isEq(a[i],v) }, "\n" + Array(lGroup).description + "\n" + n.description + "\n")
        
      }
      
      let ar = Array(lGroup)
      
      XCTAssertFalse(ar.dropFirst().enumerate().contains { (i,v) in isEq(ar[i].last!, v.first!) })
      
    }
    
  }
  
  func testMostFrequent() {
    
    for _ in 0...1000 {
      let nums = (1...10).map { _ in Int.randLim(20) }
      
      let mostFreq = nums.mostFrequent()!
      
      let freqs = nums.freqs()
      
      let occurances = freqs[mostFreq]
      
      XCTAssertFalse(freqs.values.contains { $0 > occurances}, "\n" + mostFreq.description + " " + freqs.debugDescription)
    }
  }
}