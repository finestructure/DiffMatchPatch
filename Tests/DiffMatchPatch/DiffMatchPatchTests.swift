import XCTest
@testable import DiffMatchPatch

class DiffMatchPatchTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(DiffMatchPatch().text, "Hello, World!")
    }


    static var allTests : [(String, (DiffMatchPatchTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
