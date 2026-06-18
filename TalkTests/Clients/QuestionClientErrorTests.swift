import Testing
import Foundation
@testable import Talk

@Suite("QuestionClientError")
struct QuestionClientErrorTests {

    @Test func fileNotFound_errorDescription_containsFileName() {
        let error = QuestionClientError.fileNotFound("couple.json")
        #expect(error.errorDescription == "File not found: couple.json")
    }

    @Test func fileNotFound_errorDescription_isNotNil() {
        let error = QuestionClientError.fileNotFound("daily.json")
        #expect(error.errorDescription != nil)
    }

    @Test func emptyDailyQuestions_errorDescription() {
        let error = QuestionClientError.emptyDailyQuestions
        #expect(error.errorDescription == "daily.json contains no questions")
    }

    @Test func emptyDailyQuestions_errorDescription_isNotNil() {
        let error = QuestionClientError.emptyDailyQuestions
        #expect(error.errorDescription != nil)
    }

    @Test func localizedError_conformance() {
        let error: LocalizedError = QuestionClientError.fileNotFound("x.json")
        #expect(error.errorDescription != nil)
    }
}
