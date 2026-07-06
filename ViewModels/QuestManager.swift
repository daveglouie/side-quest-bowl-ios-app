import Foundation
import SwiftUI

class QuestManager: ObservableObject {
    @Published var quests: [SideQuest] = []
    @Published var userProfile: UserProfile = UserProfile()

    private let questsKey = "saved_quests"
    private let profileKey = "user_profile"

    init() {
        loadQuests()
        loadProfile()
    }

    func addQuest(_ quest: SideQuest) {
        quests.append(quest)
        saveQuests()
    }

    func getRandomQuest(difficulty: QuestDifficulty? = nil) -> SideQuest? {
        let availableQuests = quests.filter { !$0.isCompleted }

        if let difficulty = difficulty {
            let filteredQuests = availableQuests.filter { $0.difficulty == difficulty }
            return filteredQuests.randomElement()
        }

        return availableQuests.randomElement()
    }

    func completeQuest(_ quest: SideQuest, photoData: Data?) {
        if let index = quests.firstIndex(where: { $0.id == quest.id }) {
            quests[index].isCompleted = true
            quests[index].completedDate = Date()
            quests[index].photoEvidence = photoData

            userProfile.addXP(quest.xpReward)
            userProfile.addCoins(quest.coinReward)
            userProfile.completeQuest()

            saveQuests()
            saveProfile()
        }
    }

    private func saveQuests() {
        if let encoded = try? JSONEncoder().encode(quests) {
            UserDefaults.standard.set(encoded, forKey: questsKey)
        }
    }

    private func loadQuests() {
        if let data = UserDefaults.standard.data(forKey: questsKey),
           let decoded = try? JSONDecoder().decode([SideQuest].self, from: data) {
            quests = decoded
        }
    }

    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }

    private func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }
}
