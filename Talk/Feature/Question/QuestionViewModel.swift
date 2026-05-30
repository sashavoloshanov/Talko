import Foundation
import Observation
 
@Observable
final class QuestionViewModel: BaseViewModel {
    let questions: [CardQuestion]
    let subcategoryId: String
    private(set) var currentIndex: Int
    private(set) var likedIds: Set<String>
 
    var current: CardQuestion { questions[currentIndex] }
    var canGoNext: Bool { currentIndex < questions.count - 1 }
    var canGoPrevious: Bool { currentIndex > 0 }
    var progress: String { "\(currentIndex + 1) / \(questions.count)" }
    var progressValue: Double { Double(currentIndex + 1) / Double(questions.count) }
    var isCurrentLiked: Bool { likedIds.contains(current.id) }
 
    init(questions: [CardQuestion], subcategoryId: String) {
        self.questions = questions
        self.subcategoryId = subcategoryId
        let progress = UserDefaultsClient.get([String: Int].self, for: .subcategoryProgress) ?? [:]
        self.currentIndex = min(progress[subcategoryId] ?? 0, max(0, questions.count - 1))
        let liked = UserDefaultsClient.get([String].self, for: .likedQuestions) ?? []
        self.likedIds = Set(liked)
    }
 
    func next() {
        guard canGoNext else { return }
        currentIndex += 1
        saveProgress()
    }
 
    func previous() {
        guard canGoPrevious else { return }
        currentIndex -= 1
        #if DEBUG
        saveProgress()
        #endif
    }
 
    func toggleLike() {
        let id = current.id
        if likedIds.contains(id) {
            likedIds.remove(id)
        } else {
            likedIds.insert(id)
        }
        UserDefaultsClient.set(Array(likedIds), for: .likedQuestions)
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
