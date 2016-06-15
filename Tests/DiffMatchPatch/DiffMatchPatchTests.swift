import XCTest
@testable import DiffMatchPatch

// Test helpers to keep Nimble format

struct Matcher<T: Comparable> {
    let value: T
}

func ==<T: Comparable> (lhs: Matcher<T>, rhs: Matcher<T>) {
    XCTAssertEqual(lhs.value, rhs.value)
}

func ==<T: Comparable> (lhs: Matcher<T>, rhs: T) {
    XCTAssertEqual(lhs.value, rhs)
}

func expect<T: Comparable>(_ value: T) -> Matcher<T> {
    return Matcher(value: value)
}

// make Operation Comparable
func == (lhs: Operation, rhs: Operation) -> Bool {
    return lhs == rhs
}

class DiffMatchPatchTests: XCTestCase {
    func test_computeDiff() {
        let d = computeDiff(a: "foo2bar", b: "foobar")
        expect(d.count) == 3
        // expect(d[0].operation) == Operation.DiffEqual
        expect(d[0].text) == "foo"
        // expect(d[1].operation) == Operation.DiffDelete
        expect(d[1].text) == "2"
        // expect(d[2].operation) == Operation.DiffEqual
        expect(d[2].text) == "bar"
    }


    static var allTests : [(String, (DiffMatchPatchTests) -> () throws -> Void)] {
        return [
            ("test_computeDiff", test_computeDiff),
        ]
    }
}
