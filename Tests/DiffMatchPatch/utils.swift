import XCTest

// Test helpers to keep Nimble format

struct Matcher<T: Equatable> {
    let value: T
}

func ==<T: Equatable> (lhs: Matcher<T>, rhs: Matcher<T>) {
    XCTAssertEqual(lhs.value, rhs.value)
}

func ==<T: Equatable> (lhs: Matcher<T>, rhs: T) {
    XCTAssertEqual(lhs.value, rhs)
}

func expect<T: Equatable>(_ value: T) -> Matcher<T> {
    return Matcher(value: value)
}
