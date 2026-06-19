import SwiftUI
import WebKit

struct DocumentView: View {
    let document: DocumentItem

    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    coordinator.dismissSheet()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Colors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            if let url = document.localURL(languageClient.current) {
                LocalWebView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                ContentUnavailableView(
                    String(localized: "document_unavailable_title", bundle: bundle),
                    systemImage: "doc.text.fill"
                )
            }
        }
        .background(Colors.backgroundPrimary)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct LocalWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
