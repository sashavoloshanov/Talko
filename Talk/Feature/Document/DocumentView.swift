import SwiftUI
import WebKit

struct DocumentView: View {
    let document: DocumentItem

    @Environment(AppCoordinator.self) private var coordinator
    @Environment(LanguageClient.self) private var languageClient
    @Environment(\.languageBundle) private var bundle

    var body: some View {
        VStack(spacing: 0) {
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
        .background(Colors.brandDark)
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
