import SwiftUI

struct MainBowlView: View {
    @EnvironmentObject var questManager: QuestManager
    @State private var showingQuestPicker = false
    @State private var selectedDifficulty: QuestDifficulty?

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    userStatsHeader

                    Spacer()

                    bowlGraphic

                    Spacer()

                    pickQuestButton

                    difficultySelector

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Side Quest Bowl")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddQuestView()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingQuestPicker) {
                QuestPickerView(selectedDifficulty: selectedDifficulty)
            }
        }
    }

    private var userStatsHeader: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Level \(questManager.userProfile.level)")
                    .font(.title2)
                    .fontWeight(.bold)

                ProgressView(value: questManager.userProfile.currentLevelProgress)
                    .frame(width: 150)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(questManager.userProfile.totalXP) XP")
                        .fontWeight(.semibold)
                }

                HStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.orange)
                    Text("\(questManager.userProfile.questCoins) Coins")
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    private var bowlGraphic: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 250, height: 250)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 20)
                        .blur(radius: 5)
                        .offset(x: -5, y: -5)
                )

            VStack(spacing: 10) {
                ForEach(0..<3) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<(3 - row)) { _ in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 40, height: 25)
                                .rotationEffect(.degrees(Double.random(in: -15...15)))
                        }
                    }
                }
            }
            .offset(y: -20)
        }
        .shadow(radius: 10)
    }

    private var pickQuestButton: some View {
        Button(action: {
            showingQuestPicker = true
        }) {
            Text("Pick Me a Side Quest!")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }

    private var difficultySelector: some View {
        VStack(spacing: 10) {
            Text("Filter by Difficulty")
                .font(.caption)
                .foregroundColor(.gray)

            HStack(spacing: 15) {
                Button(action: { selectedDifficulty = nil }) {
                    Text("Any")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(selectedDifficulty == nil ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedDifficulty == nil ? .white : .primary)
                        .cornerRadius(10)
                }

                ForEach(QuestDifficulty.allCases, id: \.self) { difficulty in
                    Button(action: { selectedDifficulty = difficulty }) {
                        Text(difficulty.rawValue)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(selectedDifficulty == difficulty ? difficultyColor(difficulty) : Color.gray.opacity(0.2))
                            .foregroundColor(selectedDifficulty == difficulty ? .white : .primary)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }

    private func difficultyColor(_ difficulty: QuestDifficulty) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}
