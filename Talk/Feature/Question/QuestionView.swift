import SwiftUI
 
struct QuestionView: View {
    let questions: [CardQuestion]
    let subcategoryId: String
    let title: String
    var startIndex: Int? = nil
    var onUnlikeAt: ((Int) -> Void)? = nil

    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle

    @State private var viewModel: QuestionViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var slideDirection: SlideDirection = .forward

    enum SlideDirection {
        case forward, backward
    }

    init(questions: [CardQuestion], subcategoryId: String, title: String,
         startIndex: Int? = nil, onUnlikeAt: ((Int) -> Void)? = nil) {
        self.questions = questions
        self.subcategoryId = subcategoryId
        self.title = title
        self.startIndex = startIndex
        self.onUnlikeAt = onUnlikeAt
        _viewModel = State(initialValue: QuestionViewModel(questions: questions, subcategoryId: subcategoryId, forceStartIndex: startIndex))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationView
 
            progressView
 
            Spacer()
 
            cardView
                .containerRelativeFrame(.vertical) { size, _ in
                    size * 0.5
                }
 
            Spacer()
 
            buttonStackView
        }
        .hideTabBar()
        .background(Colors.backgroundPrimary)
        .navigationBarHidden(true)
        .task { await viewModel.loadState() }
    }
    
    private var navigationView: some View {
        NavigationBar(
            leftButton: { coordinator.pop() },
            centerContent: .text(title),
            rightButton: NavRightButton(
                icon: viewModel.isCurrentLiked
                    ? (UIImage(systemName: "heart.fill") ?? UIImage())
                    : (UIImage(systemName: "heart") ?? UIImage()),
                action: {
                    guard viewModel.isStateLoaded else { return }
                    let wasLiked = viewModel.isCurrentLiked
                    let idx = viewModel.currentIndex
                    viewModel.toggleLike()
                    if wasLiked, let callback = onUnlikeAt {
                        callback(idx)
                    }
                }
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
        Group {
            if let current = viewModel.current {
                QuestionCardView(text: current.text)
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
        }
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
private let previewQuestions: [CardQuestion] = [
    CardQuestion(id: "test1", text: "Test question 1?"),
    CardQuestion(id: "test2", text: "Test question 2?"),
    CardQuestion(id: "test3", text: "Test question 3?")
]

#Preview("Dark") {
    PreviewContainer(scheme: .dark) {
        QuestionView(questions: previewQuestions, subcategoryId: "test", title: "Test")
    }
}

#Preview("Light") {
    PreviewContainer(scheme: .light) {
        QuestionView(questions: previewQuestions, subcategoryId: "test", title: "Test")
    }
}
#endif
