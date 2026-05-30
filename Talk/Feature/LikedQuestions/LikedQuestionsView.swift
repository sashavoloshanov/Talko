import SwiftUI
 
struct LikedQuestionsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.languageBundle) private var bundle
    @Environment(QuestionClientHolder.self) private var questionHolder
    @State private var viewModel = LikedQuestionsViewModel()
 
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
                    title: String(localized: "liked_questions_title", bundle: bundle)
                )
            }
        }
        .hideTabBar()
        .navigationBarHidden(true)
        .onAppear {
            viewModel.load(allCategories: questionHolder.categories)
        }
    }
}

#Preview {
    LikedQuestionsView()
}
