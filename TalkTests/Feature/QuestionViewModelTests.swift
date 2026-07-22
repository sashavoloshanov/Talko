import Testing
import Foundation
@testable import Talk

private func makeQuestions(_ count: Int) -> [CardQuestion] {
    (0..<count).map { .fixture(id: "q\($0)", text: "Q\($0)") }
}

@Suite("QuestionViewModel", .serialized)
@MainActor
struct QuestionViewModelTests {

    @Suite("init")
    @MainActor
    struct Init {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.qvm.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func defaultInitStartsAt0() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.currentIndex == 0)
            #expect(vm.isStateLoaded == false)
        }

        @Test func forceStartIndex2() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 2)
            #expect(vm.currentIndex == 2)
            #expect(vm.isStateLoaded == true)
        }

        @Test func forceStartIndexClampsToCountMinus1() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 10)
            #expect(vm.currentIndex == 2)
        }

        @Test func emptyQuestionsCurrentIsNil() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: [], subcategoryId: "sub")
            #expect(vm.currentIndex == 0)
            #expect(vm.current == nil)
        }
    }

    @Suite("Computed properties")
    @MainActor
    struct ComputedProperties {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.qvm.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func canGoNextTrueInMiddle() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.canGoNext == true)
        }

        @Test func canGoNextFalseAtLast() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(1), subcategoryId: "sub")
            #expect(vm.canGoNext == false)
        }

        @Test func canGoPreviousTrueInMiddle() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 1)
            #expect(vm.canGoPrevious == true)
        }

        @Test func canGoPreviousFalseAtFirst() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.canGoPrevious == false)
        }

        @Test func progressString() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.progress == "1 / 3")
            vm.next()
            #expect(vm.progress == "2 / 3")
            vm.next()
            #expect(vm.progress == "3 / 3")
        }

        @Test func progressValueCalculation() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(4), subcategoryId: "sub")
            #expect(vm.progressValue == 1.0 / 4.0)
        }

        @Test func progressValueEmptyQuestionsIsZero() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: [], subcategoryId: "sub")
            #expect(vm.progressValue == 0)
        }

        @Test func isCurrentLiked() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            #expect(vm.isCurrentLiked(in: store) == false)
            store.toggle("q0")
            #expect(vm.isCurrentLiked(in: store) == true)
        }
    }

    @Suite("next()")
    @MainActor
    struct Next {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.qvm.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func nextIncrementsIndex() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            vm.next()
            #expect(vm.currentIndex == 1)
        }

        @Test func nextWritesProgressToDefaults() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            vm.next()
            UserDefaultsClient.defaults = defaults
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 2)
        }

        @Test func nextDoesNotExceedBounds() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(1), subcategoryId: "sub")
            vm.next()
            #expect(vm.currentIndex == 0)
        }
    }

    @Suite("previous()")
    @MainActor
    struct Previous {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.qvm.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func previousDecrementsIndex() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 2)
            vm.previous()
            #expect(vm.currentIndex == 1)
        }

        @Test func previousDoesNotGoBelowZero() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            vm.previous()
            #expect(vm.currentIndex == 0)
        }

        @Test func previousDoesNotSaveProgress() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub", forceStartIndex: 2)
            vm.previous()
            UserDefaultsClient.defaults = defaults
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == nil)
        }
    }

    @Suite("loadState()")
    @MainActor
    struct LoadState {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.qvm.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func loadStateRestoresSavedIndex() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["sub": 2], for: .subcategoryProgress)
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.currentIndex == 2)
        }

        @Test func loadStateClampsSavedIndex() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["sub": 100], for: .subcategoryProgress)
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.currentIndex == 2)
        }

        @Test func loadStateDefaultsToZeroWhenNoRecord() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.currentIndex == 0)
        }

        @Test func loadStateSetsIsStateLoaded() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let vm = QuestionViewModel(questions: makeQuestions(3), subcategoryId: "sub")
            await vm.loadState()
            #expect(vm.isStateLoaded == true)
        }

        @Test func secondLoadStateIsIgnored() async {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["sub": 2], for: .subcategoryProgress)
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub")
            await vm.loadState()
            UserDefaultsClient.defaults = defaults
            UserDefaultsClient.set(["sub": 4], for: .subcategoryProgress)
            await vm.loadState()
            #expect(vm.currentIndex == 2)
        }
    }

    @Suite("incrementProgressCount")
    @MainActor
    struct IncrementProgress {
        let defaults: UserDefaults
        let suite: String

        init() {
            suite = "com.talk.tests.qvm.\(UUID().uuidString)"
            defaults = UserDefaults(suiteName: suite)!
        }

        @Test func existing0CurrentIndex2Writes3() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 2)
            vm.toggleLike(in: store)
            UserDefaultsClient.defaults = defaults
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 3)
        }

        @Test func existing5CurrentIndex2Stays5() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["sub": 5], for: .subcategoryProgress)
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 2)
            vm.toggleLike(in: store)
            UserDefaultsClient.defaults = defaults
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 5)
        }

        @Test func existing2CurrentIndex4Writes5() {
            UserDefaultsClient.defaults = defaults
            defer { UserDefaults.standard.removePersistentDomain(forName: suite) }
            UserDefaultsClient.set(["sub": 2], for: .subcategoryProgress)
            let store = LikesStore()
            let vm = QuestionViewModel(questions: makeQuestions(5), subcategoryId: "sub", forceStartIndex: 4)
            vm.toggleLike(in: store)
            UserDefaultsClient.defaults = defaults
            let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress)
            #expect(progress?["sub"] == 5)
        }
    }
}
