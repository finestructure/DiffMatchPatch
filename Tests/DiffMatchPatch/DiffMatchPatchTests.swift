import XCTest
@testable import DiffMatchPatch

// Tests for the 'swifty' API wrapper around the ObjC diff_patch_match module

class DiffMatchPatchTests: XCTestCase {
    
    func test_computeDiff() {
        let d = computeDiff(a: "foo2bar", b: "foobar")
        expect(d.count) == 3
        expect(d[0].operation) == .diffEqual
        expect(d[0].text) == "foo"
        expect(d[1].operation) == .diffDelete
        expect(d[1].text) == "2"
        expect(d[2].operation) == .diffEqual
        expect(d[2].text) == "bar"
    }

    static var allTests : [(String, (DiffMatchPatchTests) -> () throws -> Void)] {
        return [
            ("test_computeDiff", test_computeDiff),
        ]
    }
}
