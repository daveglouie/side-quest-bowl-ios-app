import SwiftUI

struct QuestPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var questManager: QuestManager

    let selectedDifficulty: QuestDifficulty?
    @State private var currentQuest: SideQuest?
    @State private var showingNoQuestsAlert = false

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                if let quest = currentQuest {
                    questPaperView(quest: quest)

                    buttonRow
                } else {
                    noQuestsView
                }
            }
            .padding()
        }
        .onAppear {
            pickRandomQuest()
        }
        .alert("No Quests Available", isPresented: $showingNoQuestsAlert) {
            Button("Add Quests") {
                dismiss()
            }
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            if let difficulty = selectedDifficulty {
                Text("You don't have any \(difficulty.rawValue.lowercased()) quests yet. Add some quests first!")
            } else {
                Text("You don't have any quests yet. Add some quests first!")
            }
        }
    }

    private func questPaperView(quest: SideQuest) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 10)

            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 20) {
                HStack {
                    Text("SIDE QUEST")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    difficultyBadge(quest.difficulty)
                }

                Text(quest.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                if !quest.description.isEmpty {
                    Text(quest.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                Divider()

                HStack {
                    Label("\(quest.xpReward) XP", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    Spacer()
                    Label("\(quest.coinReward) Coins", systemImage: "bitcoinsign.circle.fill")
                        .foregroundColor(.orange)
                }
                .font(.caption)
                .fontWeight(.semibold)
            }
            .padding(25)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .padding(.horizontal)
        .rotationEffect(.degrees(-2))
    }

    private var noQuestsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Quests Available")
                .font(.title2)
                .fontWeight(.bold)

            Text("Add some side quests first!")
                .foregroundColor(.gray)
        }
    }

    private var buttonRow: some View {
        HStack(spacing: 15) {
            Button(action: pickRandomQuest) {
                Text("Pick New Quest")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: { dismiss() }) {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(width: 100)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.gray)
                    .cornerRadius(10)
            }

            NavigationLink(destination: QuestAcceptView(quest: currentQuest!)) {
                Text("Accept Quest")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }

    private func difficultyBadge(_ difficulty: QuestDifficulty) -> some View {
        Text(difficulty.rawValue.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(difficultyColor(difficulty))
            .foregroundColor(.white)
            .cornerRadius(5)
    }

    private func difficultyColor(_ difficulty: QuestDifficulty) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }

    private func pickRandomQuest() {
        if let quest = questManager.getRandomQuest(difficulty: selectedDifficulty) {
            currentQuest = quest
        } else {
            showingNoQuestsAlert = true
        }
    }
}
