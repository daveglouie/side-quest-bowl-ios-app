import Foundation

struct UserProfile: Codable {
    var totalXP: Int = 0
    var questCoins: Int = 0
    var level: Int = 1
    var completedQuests: Int = 0

    var xpForNextLevel: Int {
        level * 100
    }

    var currentLevelProgress: Double {
        let xpInCurrentLevel = totalXP % xpForNextLevel
        return Double(xpInCurrentLevel) / Double(xpForNextLevel)
    }

    mutating func addXP(_ amount: Int) {
        totalXP += amount
        updateLevel()
    }

    mutating func addCoins(_ amount: Int) {
        questCoins += amount
    }

    mutating func completeQuest() {
        completedQuests += 1
    }

    private mutating func updateLevel() {
        while totalXP >= xpForNextLevel {
            level += 1
        }
    }
}
