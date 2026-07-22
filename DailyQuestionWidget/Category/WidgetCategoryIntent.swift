import AppIntents

struct NextQuestionIntent: AppIntent {
    static var title: LocalizedStringResource = "Hext"

    @Parameter(title: "Category ID")
    var categoryId: String

    init() {}
    init(categoryId: String) { self.categoryId = categoryId }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: AppGroupKey.suiteName)
        let key = AppGroupKey.widgetIndex(categoryId: categoryId)
        let count = loadCount(from: defaults)
        let current = defaults?.integer(forKey: key) ?? 0
        defaults?.set((current + 1) % max(count, 1), forKey: key)
        return .result()
    }

    private func loadCount(from defaults: UserDefaults?) -> Int {
        guard
            let data = defaults?.data(forKey: AppGroupKey.widgetCategory(categoryId: categoryId)),
            let payload = try? JSONDecoder().decode(WidgetCategoryPayload.self, from: data)
        else { return 1 }
        return payload.questions.count
    }
}

struct PrevQuestionIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous"

    @Parameter(title: "Category ID")
    var categoryId: String

    init() {}
    init(categoryId: String) { self.categoryId = categoryId }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: AppGroupKey.suiteName)
        let key = AppGroupKey.widgetIndex(categoryId: categoryId)
        let count = loadCount(from: defaults)
        let current = defaults?.integer(forKey: key) ?? 0
        defaults?.set(current == 0 ? count - 1 : current - 1, forKey: key)
        return .result()
    }

    private func loadCount(from defaults: UserDefaults?) -> Int {
        guard
            let data = defaults?.data(forKey: AppGroupKey.widgetCategory(categoryId: categoryId)),
            let payload = try? JSONDecoder().decode(WidgetCategoryPayload.self, from: data)
        else { return 1 }
        return payload.questions.count
    }
}
