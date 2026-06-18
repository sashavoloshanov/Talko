import Testing
import Foundation
@testable import Talk

@Suite("Badge")
@MainActor
struct BadgeTests {

    private func badge(id: String, isEarned: Bool = true) -> Badge {
        Badge(id: id, subcategoryId: "sub_\(id)", subcategoryName: "Name", isEarned: isEarned, imageName: "img_\(id)", name: "Name")
    }

    @Suite("Equatable (==)")
    @MainActor
    struct Equality {
        @Test func sameid_areEqual() {
            let a = Badge(id: "x", subcategoryId: "sub1", subcategoryName: "A", isEarned: true, imageName: "img1", name: "A")
            let b = Badge(id: "x", subcategoryId: "sub2", subcategoryName: "B", isEarned: false, imageName: "img2", name: "B")
            #expect(a == b)
        }

        @Test func differentId_areNotEqual() {
            let a = Badge(id: "x", subcategoryId: "sub1", subcategoryName: "A", isEarned: true, imageName: "img1", name: "A")
            let b = Badge(id: "y", subcategoryId: "sub1", subcategoryName: "A", isEarned: true, imageName: "img1", name: "A")
            #expect(a != b)
        }

        @Test func onlyIdMatters_otherFieldsDiffer() {
            let base = Badge(id: "z", subcategoryId: "s", subcategoryName: "N", isEarned: true, imageName: "i", name: "N")
            let other = Badge(id: "z", subcategoryId: "different", subcategoryName: "Different", isEarned: false, imageName: "different", name: "Different")
            #expect(base == other)
        }
    }

    @Suite("Hashable")
    @MainActor
    struct Hashing {
        @Test func equalBadgesHaveSameHash() {
            let a = Badge(id: "h1", subcategoryId: "s1", subcategoryName: "A", isEarned: true, imageName: "i1", name: "A")
            let b = Badge(id: "h1", subcategoryId: "s2", subcategoryName: "B", isEarned: false, imageName: "i2", name: "B")
            #expect(a.hashValue == b.hashValue)
        }

        @Test func canBeUsedInSet() {
            let a = Badge(id: "s1", subcategoryId: "x", subcategoryName: "X", isEarned: true, imageName: "i", name: "X")
            let b = Badge(id: "s1", subcategoryId: "y", subcategoryName: "Y", isEarned: false, imageName: "j", name: "Y")
            let set: Set<Badge> = [a, b]
            #expect(set.count == 1)
        }
    }
}
