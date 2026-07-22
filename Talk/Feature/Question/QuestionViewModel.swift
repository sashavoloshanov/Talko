import Foundation
import Observation

@Observable
final class QuestionViewModel: BaseViewModel {
    let questions: [CardQuestion]
    let subcategoryId: String
    private(set) var currentIndex: Int
    private(set) var isStateLoaded: Bool
    private let forceStartIndex: Int?

    var current: CardQuestion? {
        guard !questions.isEmpty, questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }
    var canGoNext: Bool { currentIndex < questions.count - 1 }
    var canGoPrevious: Bool { currentIndex > 0 }
    var progress: String { "\(currentIndex + 1) / \(questions.count)" }
    var progressValue: Double { questions.isEmpty ? 0 : Double(currentIndex + 1) / Double(questions.count) }
    func isCurrentLiked(in store: LikesStore) -> Bool { current.map { store.likedIds.contains($0.id) } ?? false }

    init(questions: [CardQuestion], subcategoryId: String, forceStartIndex: Int? = nil) {
        self.questions = questions
        self.subcategoryId = subcategoryId
        self.forceStartIndex = forceStartIndex
        if let forced = forceStartIndex {
            self.currentIndex = min(forced, max(0, questions.count - 1))
            self.isStateLoaded = true
        } else {
            self.currentIndex = 0
            self.isStateLoaded = false
        }
    }

    func loadState() async {
        guard !isStateLoaded else { return }
        let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress) ?? [:]
        let savedIndex = min(progress[subcategoryId] ?? 0, max(0, questions.count - 1))
        await MainActor.run {
            currentIndex = savedIndex
            isStateLoaded = true
        }
    }

    func next() {
        guard canGoNext else { return }
        currentIndex += 1
        saveProgress()
    }

    func previous() {
        guard canGoPrevious else { return }
        currentIndex -= 1
    }

    func toggleLike(in store: LikesStore) {
        guard let q = current else { return }
        store.toggle(q.id)
        incrementProgressCount()
    }

    private func saveProgress() {
        var progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress) ?? [:]
        progress[subcategoryId] = currentIndex + 1
        UserDefaultsClient.set(progress, for: .subcategoryProgress)
    }

    private func incrementProgressCount() {
        var progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress) ?? [:]
        let current = progress[subcategoryId] ?? 0
        progress[subcategoryId] = max(current, currentIndex + 1)
        UserDefaultsClient.set(progress, for: .subcategoryProgress)
    }
}
