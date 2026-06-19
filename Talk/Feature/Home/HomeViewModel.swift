import Foundation
import Observation

@Observable
final class HomeViewModel: BaseViewModel {

    func isLocked(_ sub: Subcategory, isPremium: Bool) -> Bool {
        sub.isPremium && !isPremium
    }

    func hasLikedQuestions(_ store: LikesStore) -> Bool {
        !store.likedIds.isEmpty
    }

    func loadContent(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient, likesStore: LikesStore) async {
        do {
            try await holder.load(language: language)
            if !premiumClient.isPremium {
                likesStore.removePremiumLikes(categories: holder.categories)
            }
        } catch is CancellationError {
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reloadContent(holder: QuestionClientHolder, language: AppLanguage, premiumClient: PremiumClient, likesStore: LikesStore) async {
        holder.reload()
        await loadContent(holder: holder, language: language, premiumClient: premiumClient, likesStore: likesStore)
    }
}
