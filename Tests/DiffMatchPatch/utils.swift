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

// FIXME: sas 2016-06-17: remove once Swift 3.0 has substring issues cleared up
// There seems to be a problem with indexes in Swift 3.0-preview-1. The following don't work
// s.startIndex.successor()         unkown by compiler - this is the method documented to be 
//                                  the correct one going forward https://swift.org/migration-guide/
// s.startIndex.advancedBy(n: 1)    doesn't like Int
//                                  I don't know how else to come up with a Stride value for this
// Giving up fiddling with it, this is a helper to be able to proceed with the tests
extension String {
    func _substring(from: Int) -> String {
        var mutable = self
        for _ in 0..<from {
            if mutable.characters.first != nil {
                mutable.remove(at: mutable.startIndex)
            } else {
                break
            }
        }
        return mutable
    }
}
