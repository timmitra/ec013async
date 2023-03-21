//
//  WhosNextTests.swift
//  WhosNextTests
//
//  Created by Tim Mitra on 2023-03-20.
//

import XCTest
@testable import WhosNext

final class WhosNextTests: XCTestCase {
  let vendor = AsyncEntryVendor()
  let entry3 = Entry(imageName: "3.circle")

  func test_entryCreation() async throws {
    let result = await vendor.entry(for: 3)
    XCTAssertEqual(result, entry3)
  }
  
  func test_errorEntryCreation() async {
    let result = await vendor.entry(for: 5)
    XCTAssertEqual(result, errorEntry())
  }
  
  func test_imageNameCreatesEntry() async throws {
    let result = try await vendor.imageName(for: 3)
    XCTAssertEqual(result, entry3.imageName)
  }
}
