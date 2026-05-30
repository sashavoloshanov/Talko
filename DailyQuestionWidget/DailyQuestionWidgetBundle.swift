import WidgetKit
import SwiftUI

@main
struct DailyQuestionWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyQuestionWidget()
        CoupleQuestionWidget()
        FamilyQuestionWidget()
        FriendsQuestionWidget()
    }
}
