import Testing
import Foundation
@testable import Talk

@Suite("DocumentItem", .serialized)
@MainActor
struct DocumentItemTests {

    @Suite("fileName")
    @MainActor
    struct FileName {
        @Test func privacyPolicy_ukrainian() {
            #expect(DocumentItem.privacyPolicy.fileName(.ukrainian) == "privacy_policy_ua")
        }

        @Test func privacyPolicy_english() {
            #expect(DocumentItem.privacyPolicy.fileName(.english) == "privacy_policy_en")
        }

        @Test func termsOfService_ukrainian() {
            #expect(DocumentItem.termsOfService.fileName(.ukrainian) == "terms_of_use_ua")
        }

        @Test func termsOfService_english() {
            #expect(DocumentItem.termsOfService.fileName(.english) == "terms_of_use_en")
        }
    }

    @Suite("Hashable")
    @MainActor
    struct HashableConformance {
        @Test func sameCasesAreEqual() {
            #expect(DocumentItem.privacyPolicy == DocumentItem.privacyPolicy)
            #expect(DocumentItem.termsOfService == DocumentItem.termsOfService)
        }

        @Test func differentCasesAreNotEqual() {
            #expect(DocumentItem.privacyPolicy != DocumentItem.termsOfService)
        }
    }
}
