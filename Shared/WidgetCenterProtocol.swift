import WidgetKit

protocol WidgetCenterProtocol {
    func reloadTimelines(ofKind kind: String)
    func reloadAllTimelines()
}

extension WidgetCenter: WidgetCenterProtocol {}
