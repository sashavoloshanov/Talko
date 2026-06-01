import SwiftUI
 
struct LikedQuestionsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.languageBundle) private var bundle
    @Environment(QuestionClientHolder.self) private var questionHolder
    @State private var viewModel = LikedQuestionsViewModel()
    @State private var likedStartIndex: Int = 0
    @State private var likedViewVersion: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.questions.isEmpty {
                NavigationBar(
                    leftButton: { coordinator.pop() },
                    centerContent: .text(String(localized: "liked_questions_title", bundle: bundle)),
                    rightButton: nil
                )
                Spacer()
                Text(String(localized: "liked_questions_empty", bundle: bundle))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                QuestionView(
                    questions: viewModel.questions,
                    subcategoryId: "liked",
                    title: String(localized: "liked_questions_title", bundle: bundle),
                    startIndex: likedStartIndex,
                    onUnlikeAt: handleUnlike
                )
                .id(likedViewVersion)
            }
        }
        .hideTabBar()
        .navigationBarHidden(true)
        .onAppear {
            viewModel.load(allCategories: questionHolder.categories)
        }
    }

    private func handleUnlike(at index: Int) {
        let newCount = viewModel.questions.count
        guard newCount > 0 else {
            coordinator.pop()
            return
        }
        likedStartIndex = index == 0 ? 0 : index - 1
        likedViewVersion += 1
    }
}

#if DEBUG
#Preview("Dark") {
    PreviewContainer(scheme: .dark) { LikedQuestionsView() }
}

#Preview("Light") {
    PreviewContainer(scheme: .light) { LikedQuestionsView() }
}
#endif
