import SwiftUI

struct QuestAcceptView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var questManager: QuestManager

    let quest: SideQuest
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingCompletionAlert = false

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.97)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Quest Accepted!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                questDetailsCard

                photoSection

                Spacer()

                completeButton
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .alert("Quest Completed!", isPresented: $showingCompletionAlert) {
            Button("Awesome!") {
                dismiss()
            }
        } message: {
            Text("You earned \(quest.xpReward) XP and \(quest.coinReward) Quest Coins!")
        }
    }

    private var questDetailsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(quest.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                difficultyBadge(quest.difficulty)
            }

            if !quest.description.isEmpty {
                Text(quest.description)
                    .foregroundColor(.gray)
            }

            Divider()

            HStack {
                Label("XP: \(quest.xpReward)", systemImage: "star.fill")
                    .foregroundColor(.yellow)
                Spacer()
                Label("Coins: \(quest.coinReward)", systemImage: "bitcoinsign.circle.fill")
                    .foregroundColor(.orange)
            }
            .fontWeight(.semibold)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    private var photoSection: some View {
        VStack(spacing: 15) {
            Text("Take Photo Evidence")
                .font(.headline)

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.green, lineWidth: 3)
                    )
            } else {
                Button(action: { showingImagePicker = true }) {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                        Text("Tap to Take Photo")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.white)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.blue, lineWidth: 2)
                            .strokeStyle(style: StrokeStyle(lineWidth: 2, dash: [10]))
                    )
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }

    private var completeButton: some View {
        Button(action: completeQuest) {
            Text("Complete Quest")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedImage != nil ? Color.green : Color.gray)
                .cornerRadius(15)
                .shadow(radius: 5)
        }
        .disabled(selectedImage == nil)
    }

    private func difficultyBadge(_ difficulty: QuestDifficulty) -> some View {
        Text(difficulty.rawValue.uppercased())
            .font(.caption)
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

    private func completeQuest() {
        let photoData = selectedImage?.jpegData(compressionQuality: 0.8)
        questManager.completeQuest(quest, photoData: photoData)
        showingCompletionAlert = true
    }
}
