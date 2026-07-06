import SwiftUI

@main
struct SideQuestBowlApp: App {
    @StateObject private var questManager = QuestManager()

    var body: some Scene {
        WindowGroup {
            MainBowlView()
                .environmentObject(questManager)
        }
    }
}

#Preview {
    MainBowlView()
        .environmentObject(QuestManager())
}
