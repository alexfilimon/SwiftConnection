import XCTest
@testable import SwiftConnection

final class SwiftConnectionTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftConnection().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
