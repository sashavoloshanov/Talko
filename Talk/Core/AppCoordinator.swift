import SwiftUI
import Observation

enum AppRoute: Hashable {
    case question([CardQuestion], subcategoryId: String, title: String)
    case likedQuestions
}

enum AppSheet: Hashable, Identifiable {
    var id: Self { self }
    
    case document(DocumentItem)
    case subscription
}

enum AppFullScreenCover: Hashable, Identifiable {
    var id: Self { self }
    
    case badge(Badge)
}

@Observable
final class AppCoordinator {
    var path = NavigationPath()
    var sheet: AppSheet?
    var fullScreenCover: AppFullScreenCover?
    
    func push(_ route: AppRoute) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty { path.removeLast() }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func present(_ screen: AppSheet) {
        sheet = screen
    }
    
    func present(_ screen: AppFullScreenCover) {
        fullScreenCover = screen
    }
    
    func dismiss() {
        sheet = nil
        fullScreenCover = nil
    }
}
