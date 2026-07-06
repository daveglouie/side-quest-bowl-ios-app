import Foundation

enum QuestDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var xpReward: Int {
        switch self {
        case .easy: return 10
        case .medium: return 25
        case .hard: return 50
        }
    }

    var coinReward: Int {
        switch self {
        case .easy: return 5
        case .medium: return 15
        case .hard: return 30
        }
    }
}

struct SideQuest: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var difficulty: QuestDifficulty
    var isCompleted: Bool = false
    var completedDate: Date?
    var photoEvidence: Data?

    var xpReward: Int {
        difficulty.xpReward
    }

    var coinReward: Int {
        difficulty.coinReward
    }
}
