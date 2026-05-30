import SwiftUI
 
struct QuestionView: View {
    let questions: [CardQuestion]
    let subcategoryId: String
    let title: String
    
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle
    
    @State private var viewModel: QuestionViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var slideDirection: SlideDirection = .forward
 
    enum SlideDirection {
        case forward, backward
    }
 
    init(questions: [CardQuestion], subcategoryId: String, title: String) {
        self.questions = questions
        self.subcategoryId = subcategoryId
        self.title = title
        _viewModel = State(initialValue: QuestionViewModel(questions: questions, subcategoryId: subcategoryId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationView
 
            progressView
 
            Spacer()
 
            cardView
                .frame(height: UIScreen.main.bounds.height * 0.5)
 
            Spacer()
 
            buttonStackView
        }
        .hideTabBar()
        .background(Colors.backgroundPrimary)
        .navigationBarHidden(true)
    }
    
    private var navigationView: some View {
        NavigationBar(
            leftButton: { coordinator.pop() },
            centerContent: .text(title),
            rightButton: NavRightButton(
                icon: viewModel.isCurrentLiked
                    ? (UIImage(systemName: "heart.fill") ?? UIImage())
                    : (UIImage(systemName: "heart") ?? UIImage()),
                action: { viewModel.toggleLike() }
            )
        )
    }
    
    private var progressView: some View {
        CardProgressView(
            value: viewModel.progressValue,
            label: viewModel.progress
        )
        .padding(.top, 12)
    }
    
    private var cardView: some View {
        QuestionCardView(text: viewModel.current.text)
            .padding(.horizontal, 20)
            .id(viewModel.currentIndex)
            .transition(
                .asymmetric(
                    insertion: .move(edge: slideDirection == .forward ? .trailing : .leading),
                    removal: .move(edge: slideDirection == .forward ? .leading : .trailing)
                )
            )
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 {
                            slideDirection = .forward
                            withAnimation(.spring()) { viewModel.next() }
                        } else if value.translation.width > 50 {
                            slideDirection = .backward
                            withAnimation(.spring()) { viewModel.previous() }
                        }
                    }
            )
    }
    
    private var buttonStackView: some View {
        HStack(spacing: 16) {
            Button {
                slideDirection = .backward
                withAnimation(.spring()) { viewModel.previous() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(height: 56)
                    .foregroundColor(Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .background(.backgroundSecondary)
            .buttonStyle(.borderless)
            .clipShape(.capsule)
            .disabled(!viewModel.canGoPrevious)
            .opacity(viewModel.canGoPrevious ? 1 : 0.3)

            Button {
                slideDirection = .forward
                withAnimation(.spring()) { viewModel.next() }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(height: 56)
                    .foregroundColor(Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .background(.backgroundSecondary)
            .buttonStyle(.borderless)
            .clipShape(.capsule)
            .disabled(!viewModel.canGoNext)
            .opacity(viewModel.canGoNext ? 1 : 0.3)
        }
        .padding(.bottom, 40)
        .padding(.horizontal, 24)
    }
}

#if DEBUG
#Preview("Dark") {
    @Previewable @State var questionHolder = QuestionClientHolder()
    @Previewable @State var languageClient = LanguageClient()
    @Previewable @State var themeClient = ThemeClient()
    @Previewable @State var premiumClient = PremiumClient()
    @Previewable @State var coordinator = AppCoordinator()
    
    @Previewable var questions: [
        CardQuestion] = [CardQuestion(id: "test1", text: "Test question 1?"),
                         CardQuestion(id: "test2", text: "Test question 2?"),
                         CardQuestion(id: "test3", text: "Test question 3?")
        ]
    
    QuestionView(questions: questions, subcategoryId: "test", title: "Test")
        .environment(languageClient)
        .environment(\.languageBundle, languageClient.bundle)
        .environment(themeClient)
        .environment(premiumClient)
        .environment(coordinator)
        .environment(questionHolder)
        .preferredColorScheme(ColorScheme.dark)
}

#Preview("Light") {
    @Previewable @State var questionHolder = QuestionClientHolder()
    @Previewable @State var languageClient = LanguageClient()
    @Previewable @State var themeClient = ThemeClient()
    @Previewable @State var premiumClient = PremiumClient()
    @Previewable @State var coordinator = AppCoordinator()
    
    @Previewable var questions: [
        CardQuestion] = [CardQuestion(id: "test1", text: "Test question 1?"),
                         CardQuestion(id: "test2", text: "Test question 2?"),
                         CardQuestion(id: "test3", text: "Test question 3?")
        ]
    
    QuestionView(questions: questions, subcategoryId: "test", title: "Test")
        .environment(languageClient)
        .environment(\.languageBundle, languageClient.bundle)
        .environment(themeClient)
        .environment(premiumClient)
        .environment(coordinator)
        .environment(questionHolder)
        .preferredColorScheme(ColorScheme.light)
}
#endif

