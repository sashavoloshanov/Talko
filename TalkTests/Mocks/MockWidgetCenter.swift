import Foundation
@testable import Talk

final class MockWidgetCenter: WidgetCenterProtocol {
    var reloadedKinds: [String] = []
    var reloadedAll = false

    func reloadTimelines(ofKind kind: String) { reloadedKinds.append(kind) }
    func reloadAllTimelines() { reloadedAll = true }
}
