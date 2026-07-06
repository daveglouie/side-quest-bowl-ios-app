import SwiftUI

struct AddQuestView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var questManager: QuestManager

    @State private var questTitle = ""
    @State private var questDescription = ""
    @State private var selectedDifficulty: QuestDifficulty = .medium
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quest Details")) {
                    TextField("Quest Title", text: $questTitle)

                    TextField("Description (optional)", text: $questDescription, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section(header: Text("Difficulty")) {
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(QuestDifficulty.allCases, id: \.self) { difficulty in
                            HStack {
                                Text(difficulty.rawValue)
                                Spacer()
                                Text("\(difficulty.xpReward) XP • \(difficulty.coinReward) Coins")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .tag(difficulty)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section {
                    Button(action: saveQuest) {
                        Text("Add Quest to Bowl")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(questTitle.isEmpty)
                }
            }
            .navigationTitle("New Side Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Quest Added!", isPresented: $showingAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your side quest has been added to the bowl!")
            }
        }
    }

    private func saveQuest() {
        let newQuest = SideQuest(
            title: questTitle,
            description: questDescription,
            difficulty: selectedDifficulty
        )

        questManager.addQuest(newQuest)
        showingAlert = true
    }
}
