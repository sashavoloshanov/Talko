import Testing
import Foundation
@testable import Talk

@Suite("Badge")
@MainActor
struct BadgeTests {

    @Suite("Equatable (==)")
    @MainActor
    struct Equality {
        @Test func sameid_areEqual() {
            let a = Badge.fixture(id: "x", categoryId: "c1", isEarned: true)
            let b = Badge.fixture(id: "x", categoryId: "c2", isEarned: false)
            #expect(a == b)
        }

        @Test func differentId_areNotEqual() {
            let a = Badge.fixture(id: "x")
            let b = Badge.fixture(id: "y")
            #expect(a != b)
        }

        @Test func onlyIdMatters_otherFieldsDiffer() {
            let base = Badge.fixture(id: "z", tier: 1, threshold: 10, progress: 5, isEarned: true)
            let other = Badge.fixture(id: "z", tier: 3, threshold: 50, progress: 50, isEarned: false)
            #expect(base == other)
        }
    }

    @Suite("Hashable")
    @MainActor
    struct Hashing {
        @Test func equalBadgesHaveSameHash() {
            let a = Badge.fixture(id: "h1", categoryId: "c1", isEarned: true)
            let b = Badge.fixture(id: "h1", categoryId: "c2", isEarned: false)
            #expect(a.hashValue == b.hashValue)
        }

        @Test func canBeUsedInSet() {
            let a = Badge.fixture(id: "s1", categoryName: "X")
            let b = Badge.fixture(id: "s1", categoryName: "Y")
            let set: Set<Badge> = [a, b]
            #expect(set.count == 1)
        }
    }
}
