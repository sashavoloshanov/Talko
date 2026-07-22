import Foundation
import Observation

@Observable
final class HomeViewModel: BaseViewModel {

    @ObservationIgnored private var holder: QuestionClientHolder?
    @ObservationIgnored private var languageClient: LanguageClient?
    @ObservationIgnored private var premiumClient: PremiumClient?
    @ObservationIgnored private var likesStore: LikesStore?

    func setup(holder: QuestionClientHolder, languageClient: LanguageClient, premiumClient: PremiumClient, likesStore: LikesStore) {
        self.holder = holder
        self.languageClient = languageClient
        self.premiumClient = premiumClient
        self.likesStore = likesStore
    }

    func isLocked(_ sub: Subcategory, isPremium: Bool) -> Bool {
        sub.isPremium && !isPremium
    }

    func hasLikedQuestions(_ store: LikesStore) -> Bool {
        !store.likedIds.isEmpty
    }

    func loadContent() async {
        guard let holder, let languageClient, let premiumClient, let likesStore else { return }
        do {
            try await holder.load(language: languageClient.current)
            if !premiumClient.isPremium {
                likesStore.removePremiumLikes(categories: holder.categories)
            }
        } catch is CancellationError {
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reloadContent() async {
        holder?.reload()
        await loadContent()
    }
}
