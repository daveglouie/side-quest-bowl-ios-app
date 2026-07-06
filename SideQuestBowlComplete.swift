import SwiftUI
import AVFoundation

// MARK: - Models

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

enum QuestAd: String, Codable {
    case rileysDogWalking
    case ninjaCreami
    case stretchLab

    var sponsorName: String {
        switch self {
        case .rileysDogWalking: return "Riley's Dog Walking"
        case .ninjaCreami: return "Ninja Creami Deluxe"
        case .stretchLab: return "StretchLab"
        }
    }

    var tagline: String {
        switch self {
        case .rileysDogWalking: return "Professional care for your pup!"
        case .ninjaCreami: return "Make ice cream in minutes!"
        case .stretchLab: return "Assisted stretching for better mobility"
        }
    }

    var iconName: String {
        switch self {
        case .rileysDogWalking: return "pawprint.fill"
        case .ninjaCreami: return "snowflake"
        case .stretchLab: return "figure.flexibility"
        }
    }

    var ctaText: String {
        switch self {
        case .rileysDogWalking: return "Book Now →"
        case .ninjaCreami: return "Shop Now →"
        case .stretchLab: return "Book Session →"
        }
    }

    var gradientColors: (Color, Color) {
        switch self {
        case .rileysDogWalking: return (Color.green.opacity(0.3), Color.blue.opacity(0.3))
        case .ninjaCreami: return (Color.blue.opacity(0.3), Color.purple.opacity(0.3))
        case .stretchLab: return (Color.orange.opacity(0.3), Color.red.opacity(0.3))
        }
    }

    var accentColor: Color {
        switch self {
        case .rileysDogWalking: return .green
        case .ninjaCreami: return .blue
        case .stretchLab: return .orange
        }
    }

    var shadowColor: Color {
        switch self {
        case .rileysDogWalking: return .green.opacity(0.2)
        case .ninjaCreami: return .blue.opacity(0.2)
        case .stretchLab: return .orange.opacity(0.2)
        }
    }
}

struct QuestCompletion: Codable, Identifiable {
    var id = UUID()
    var completedDate: Date
    var earnedXP: Int
    var earnedCoins: Int
}

struct SideQuest: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var difficulty: QuestDifficulty
    var completions: [QuestCompletion] = []
    var acceptedDate: Date?
    var timeoutDate: Date?
    private(set) var sponsoredAd: QuestAd? = nil
    var completionTimeMinutes: Int = 30

    var xpReward: Int {
        difficulty.xpReward
    }

    var coinReward: Int {
        difficulty.coinReward
    }

    var timesCompleted: Int {
        completions.count
    }

    var lastCompletedDate: Date? {
        completions.last?.completedDate
    }

    var isActive: Bool {
        acceptedDate != nil
    }

    var isExpired: Bool {
        guard let timeoutDate = timeoutDate else { return false }
        return Date() > timeoutDate
    }

    var remainingSeconds: Int {
        guard let timeoutDate = timeoutDate else { return 0 }
        return max(0, Int(timeoutDate.timeIntervalSince(Date())))
    }

    // Internal initializer that allows setting the ad (for default quests only)
    internal init(id: UUID = UUID(), title: String, description: String, difficulty: QuestDifficulty, completions: [QuestCompletion] = [], acceptedDate: Date? = nil, timeoutDate: Date? = nil, sponsoredAd: QuestAd? = nil, completionTimeMinutes: Int = 30) {
        self.id = id
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.completions = completions
        self.acceptedDate = acceptedDate
        self.timeoutDate = timeoutDate
        self.sponsoredAd = sponsoredAd
        self.completionTimeMinutes = completionTimeMinutes
    }
}

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

// MARK: - ViewModel

class QuestManager: ObservableObject {
    @Published var quests: [SideQuest] = []
    @Published var userProfile: UserProfile = UserProfile()

    private let questsKey = "saved_quests"
    private let profileKey = "user_profile"

    init() {
        loadQuests()
        loadProfile()
        addDefaultQuestsIfNeeded()
    }

    private func addDefaultQuestsIfNeeded() {
        if quests.isEmpty {
            let defaultQuests = [
                SideQuest(
                    title: "Walk the dog",
                    description: "",
                    difficulty: .medium,
                    sponsoredAd: .rileysDogWalking,
                    completionTimeMinutes: 60
                ),
                SideQuest(
                    title: "Prep Ninja Creami",
                    description: "",
                    difficulty: .easy,
                    sponsoredAd: .ninjaCreami,
                    completionTimeMinutes: 15
                ),
                SideQuest(
                    title: "Stretch",
                    description: "",
                    difficulty: .easy,
                    sponsoredAd: .stretchLab,
                    completionTimeMinutes: 30
                )
            ]

            for quest in defaultQuests {
                addQuest(quest)
            }
        }
    }

    func addQuest(_ quest: SideQuest) {
        quests.append(quest)
        saveQuests()
    }

    var activeQuest: SideQuest? {
        quests.first { $0.isActive && !$0.isExpired }
    }

    func getRandomQuest(difficulty: QuestDifficulty? = nil) -> SideQuest? {
        let availableQuests = quests.filter { !$0.isActive }

        if let difficulty = difficulty {
            let filteredQuests = availableQuests.filter { $0.difficulty == difficulty }
            return filteredQuests.randomElement()
        }

        return availableQuests.randomElement()
    }

    func acceptQuest(_ quest: SideQuest) {
        if let index = quests.firstIndex(where: { $0.id == quest.id }) {
            let now = Date()
            quests[index].acceptedDate = now
            quests[index].timeoutDate = now.addingTimeInterval(TimeInterval(quest.completionTimeMinutes * 60))
            saveQuests()
        }
    }

    func completeQuest(_ quest: SideQuest) {
        if let index = quests.firstIndex(where: { $0.id == quest.id }) {
            if !quests[index].isExpired {
                let completion = QuestCompletion(
                    completedDate: Date(),
                    earnedXP: quest.xpReward,
                    earnedCoins: quest.coinReward
                )
                quests[index].completions.append(completion)

                userProfile.addXP(quest.xpReward)
                userProfile.addCoins(quest.coinReward)
                userProfile.completeQuest()

                saveProfile()
            }

            quests[index].acceptedDate = nil
            quests[index].timeoutDate = nil
            saveQuests()
        }
    }

    func cancelQuest(_ quest: SideQuest) {
        if let index = quests.firstIndex(where: { $0.id == quest.id }) {
            quests[index].acceptedDate = nil
            quests[index].timeoutDate = nil
            saveQuests()
        }
    }

    func checkExpiredQuests() {
        var needsSave = false
        for index in quests.indices {
            if quests[index].isActive && quests[index].isExpired {
                quests[index].acceptedDate = nil
                quests[index].timeoutDate = nil
                needsSave = true
            }
        }
        if needsSave {
            saveQuests()
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

// MARK: - Main App

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

// MARK: - Views

enum CelebrationType: CaseIterable {
    case money, fireworks, thumbsUp, burstIn, laughing

    static func random() -> CelebrationType {
        allCases.randomElement() ?? .money
    }
}

struct CelebrationParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var rotation: Double
    var scale: Double
    var opacity: Double
    let symbol: String
    let color: Color
}

struct CelebrationView: View {
    let type: CelebrationType
    @State private var particles: [CelebrationParticle] = []
    @State private var isAnimating = false
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.symbol)
                    .font(.system(size: 30))
                    .foregroundColor(particle.color)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .rotationEffect(.degrees(particle.rotation))
                    .position(particle.position)
            }
        }
        .onAppear {
            startCelebration()
            playSound()
        }
    }

    private func playSound() {
        // Use different sounds for burst animation
        if type == .burstIn {
            // Deep, impactful sound for burst effect
            AudioServicesPlaySystemSound(1520) // Peek (deep sound)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                AudioServicesPlaySystemSound(1521) // Pop (explosive sound)
            }
        } else if type == .laughing {
            // Multiple quick sounds to simulate laughter rhythm
            AudioServicesPlaySystemSound(1104) // Quick tap sound
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                AudioServicesPlaySystemSound(1104)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AudioServicesPlaySystemSound(1104)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                AudioServicesPlaySystemSound(1105) // Higher pitched
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AudioServicesPlaySystemSound(1104)
            }
        } else {
            // Randomly select a celebration sound for other animations
            let celebrationSounds: [SystemSoundID] = [
                1025,  // Success chime
                1026,  // Alert tone
                1027,  // Anticipate
                1054,  // Fanfare/horn sound
                1055,  // Triumph
                1113,  // Celebration sound
            ]

            let randomSound = celebrationSounds.randomElement() ?? 1025
            AudioServicesPlaySystemSound(randomSound)

            // Play an additional celebratory chime for variety
            if Bool.random() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    AudioServicesPlaySystemSound(1013) // Additional chime
                }
            }
        }

        // Add haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func startCelebration() {
        let symbols: [(String, Color)]

        switch type {
        case .money:
            symbols = [
                ("💵", .green),
                ("💰", .yellow),
                ("💸", .green),
                ("🪙", .orange),
                ("💲", .green)
            ]
        case .fireworks:
            symbols = [
                ("✨", .yellow),
                ("🎆", .purple),
                ("🎇", .red),
                ("⭐️", .yellow),
                ("💫", .blue),
                ("🌟", .orange)
            ]
        case .thumbsUp:
            symbols = [
                ("👍", .yellow),
                ("👍🏻", .blue),
                ("👍🏼", .green),
                ("👍🏽", .orange),
                ("👍🏾", .purple),
                ("👍🏿", .red)
            ]
        case .burstIn:
            symbols = [
                ("💥", .red),
                ("🔥", .orange),
                ("⚡️", .yellow),
                ("💫", .blue),
                ("🌟", .yellow),
                ("✨", .white),
                ("💢", .red),
                ("🎉", .red)
            ]
        case .laughing:
            symbols = [
                ("😂", .yellow),
                ("🤣", .orange),
                ("😆", .blue),
                ("😄", .green),
                ("😁", .purple),
                ("HA", .red),
                ("HE", .blue),
                ("HO", .green)
            ]
        }

        // Create 50 particles
        for i in 0..<50 {
            let randomSymbol = symbols.randomElement()!

            let startX: CGFloat
            let startY: CGFloat
            let velocityX: CGFloat
            let velocityY: CGFloat

            if type == .burstIn {
                // Burst from center outward
                let centerX = UIScreen.main.bounds.width / 2
                let centerY = UIScreen.main.bounds.height / 2
                startX = centerX
                startY = centerY

                // Explode outward in all directions
                let angle = Double.random(in: 0...(2 * .pi))
                let speed = CGFloat.random(in: 300...600)
                velocityX = cos(angle) * speed
                velocityY = sin(angle) * speed
            } else if type == .laughing {
                // Bounce up from bottom with laughing motion
                startX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                startY = UIScreen.main.bounds.height + 50  // Start below screen
                velocityX = CGFloat.random(in: -80...80)
                velocityY = CGFloat.random(in: -500...(-300))  // Shoot upward
            } else {
                // All other animations start from top and fall downward
                startX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
                startY = -50  // Start above screen
                velocityX = CGFloat.random(in: -50...50)
                velocityY = CGFloat.random(in: 400...700)  // Fall downward faster
            }

            let particle = CelebrationParticle(
                position: CGPoint(x: startX, y: startY),
                velocity: CGPoint(x: velocityX, y: velocityY),
                rotation: Double.random(in: 0...360),
                scale: Double.random(in: type == .burstIn ? 1.2...2.0 : 0.8...1.5),
                opacity: 1.0,
                symbol: randomSymbol.0,
                color: randomSymbol.1
            )

            particles.append(particle)

            // Animate each particle with slight delay for cascading effect
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.015) {
                animateParticle(at: i)
            }
        }

        // Clear particles after animation (longer duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            particles.removeAll()
        }
    }

    private func animateParticle(at index: Int) {
        guard index < particles.count else { return }

        let duration: Double = 2.5  // Faster animation duration

        withAnimation(.linear(duration: duration)) {
            particles[index].position.x += particles[index].velocity.x
            particles[index].position.y += particles[index].velocity.y
            particles[index].rotation += 360
            particles[index].opacity = 0
            particles[index].scale *= 1.5
        }
    }
}

struct MainBowlView: View {
    @EnvironmentObject var questManager: QuestManager
    @State private var showingQuestPicker = false
    @State private var showingAddQuest = false
    @State private var showingHelp = false
    @State private var showingHistory = false
    @State private var selectedDifficulty: QuestDifficulty?
    @State private var showingCelebration = false
    @State private var celebrationType: CelebrationType = .money

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    userStatsHeader

                    Spacer()

                    if let activeQuest = questManager.activeQuest {
                        activeQuestTimer(activeQuest)
                    } else {
                        bowlGraphic
                    }

                    Spacer()

                    if questManager.activeQuest == nil {
                        pickQuestButton
                        difficultySelector
                    }

                    Spacer()
                }
                .padding()

                if showingCelebration {
                    CelebrationView(type: celebrationType)
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle("Side Quest Bowl")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        Button(action: { showingHelp = true }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        Button(action: { showingAddQuest = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingQuestPicker) {
                QuestPickerSheet(selectedDifficulty: selectedDifficulty)
            }
            .sheet(isPresented: $showingAddQuest) {
                AddQuestSheet()
            }
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
            .sheet(isPresented: $showingHistory) {
                QuestHistoryView()
            }
        }
    }

    private var userStatsHeader: some View {
        Button(action: { showingHistory = true }) {
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Level \(questManager.userProfile.level)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }

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
                            .foregroundColor(.primary)
                    }

                    HStack {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.orange)
                        Text("\(questManager.userProfile.questCoins) Coins")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
        }
        .buttonStyle(.plain)
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

    private func activeQuestTimer(_ quest: SideQuest) -> some View {
        TimelineView(.periodic(from: Date(), by: 1.0)) { context in
            VStack(spacing: 20) {
                Text("Active Quest")
                    .font(.headline)
                    .foregroundColor(.gray)

                Text(quest.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                        .frame(width: 200, height: 200)

                    Circle()
                        .trim(from: 0, to: timerProgress(quest))
                        .stroke(
                            timerColor(quest),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: quest.remainingSeconds)

                    VStack(spacing: 5) {
                        Text(formatTime(quest.remainingSeconds))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(timerColor(quest))

                        Text(quest.remainingSeconds > 60 ? "minutes left" : "seconds left")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                HStack(spacing: 12) {
                    Label("\(quest.xpReward) XP", systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    Label("\(quest.coinReward) Coins", systemImage: "bitcoinsign.circle.fill")
                        .foregroundColor(.orange)
                }
                .fontWeight(.semibold)

                HStack(spacing: 15) {
                    Button(action: {
                        questManager.cancelQuest(quest)
                    }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.gray)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        if !quest.isExpired {
                            celebrationType = CelebrationType.random()
                            showingCelebration = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                showingCelebration = false
                            }
                        }
                        questManager.completeQuest(quest)
                    }) {
                        Text("Complete Quest")
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
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal)
            .onChange(of: context.date) { _ in
                questManager.checkExpiredQuests()
            }
        }
    }

    private func timerProgress(_ quest: SideQuest) -> Double {
        let totalSeconds = Double(quest.completionTimeMinutes * 60)
        let remaining = Double(quest.remainingSeconds)
        return remaining / totalSeconds
    }

    private func timerColor(_ quest: SideQuest) -> Color {
        let progress = timerProgress(quest)
        if progress > 0.5 {
            return .green
        } else if progress > 0.25 {
            return .orange
        } else {
            return .red
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return "\(remainingSeconds)"
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

struct AddQuestSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var questManager: QuestManager

    @State private var questTitle = ""
    @State private var questDescription = ""
    @State private var selectedDifficulty: QuestDifficulty = .medium

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quest Details")) {
                    TextField("Quest Title", text: $questTitle)
                    TextField("Description", text: $questDescription, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section(header: Text("Difficulty")) {
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(QuestDifficulty.allCases, id: \.self) { difficulty in
                            Text("\(difficulty.rawValue) - \(difficulty.xpReward) XP")
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Button("Add Quest") {
                    let quest = SideQuest(
                        title: questTitle,
                        description: questDescription,
                        difficulty: selectedDifficulty
                    )
                    questManager.addQuest(quest)
                    dismiss()
                }
                .disabled(questTitle.isEmpty)
            }
            .navigationTitle("New Quest")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct QuestPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var questManager: QuestManager

    let selectedDifficulty: QuestDifficulty?
    @State private var currentQuest: SideQuest?
    @State private var showingAcceptView = false
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                if let quest = currentQuest {
                    VStack(spacing: 20) {
                        Spacer()

                        questPaper(quest)

                        bannerAd(for: quest)

                        buttonRow

                        Spacer()
                    }
                    .padding()
                } else {
                    VStack {
                        Text("No quests available!")
                        Button("Add Some Quests") {
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Pick a Quest")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                currentQuest = questManager.getRandomQuest(difficulty: selectedDifficulty)
            }
            .sheet(isPresented: $showingAcceptView) {
                if let quest = currentQuest {
                    AcceptQuestView(quest: quest)
                }
            }
        }
    }

    private func questPaper(_ quest: SideQuest) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(quest.title)
                    .font(.title)
                    .fontWeight(.bold)

                if quest.timesCompleted > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "repeat.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("Completed \(quest.timesCompleted) time\(quest.timesCompleted == 1 ? "" : "s")")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }

            if !quest.description.isEmpty {
                Text(quest.description)
                    .foregroundColor(.gray)
            }

            HStack {
                Label("\(quest.xpReward) XP", systemImage: "star.fill")
                    .foregroundColor(.yellow)
                Spacer()
                Label("\(quest.coinReward) Coins", systemImage: "bitcoinsign.circle.fill")
                    .foregroundColor(.orange)
            }
            .fontWeight(.semibold)

            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                Text("\(quest.completionTimeMinutes) min time limit")
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .font(.caption)

            Text("👉 Swipe to pick another")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 5)
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .rotationEffect(.degrees(-2 + Double(dragOffset) / 20))
        .offset(x: dragOffset, y: abs(dragOffset) / 10)
        .opacity(1 - Double(abs(dragOffset)) / 400)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation.width
                }
                .onEnded { gesture in
                    if abs(gesture.translation.width) > 100 {
                        pickNewQuest()
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }

    private func pickNewQuest() {
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = dragOffset > 0 ? 500 : -500
            isAnimating = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let previousQuestId = currentQuest?.id
            var newQuest = questManager.getRandomQuest(difficulty: selectedDifficulty)

            // Keep trying until we get a different quest (or run out of quests)
            var attempts = 0
            let maxAttempts = 10
            while newQuest?.id == previousQuestId && attempts < maxAttempts {
                newQuest = questManager.getRandomQuest(difficulty: selectedDifficulty)
                attempts += 1
            }

            currentQuest = newQuest
            dragOffset = dragOffset > 0 ? -500 : 500

            withAnimation(.spring()) {
                dragOffset = 0
                isAnimating = false
            }
        }
    }

    private func bannerAd(for quest: SideQuest) -> some View {
        Group {
            if let ad = quest.sponsoredAd {
                sponsoredAdView(ad: ad)
            } else {
                genericAdPlaceholder
            }
        }
        .frame(height: 100)
    }

    private func sponsoredAdView(ad: QuestAd) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                Text("SPONSORED")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            }

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [ad.gradientColors.0, ad.gradientColors.1]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)

                    Image(systemName: ad.iconName)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(ad.sponsorName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(ad.tagline)
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(ad.ctaText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ad.accentColor)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: ad.shadowColor, radius: 5, x: 0, y: 2)
    }

    private var genericAdPlaceholder: some View {
        VStack(spacing: 8) {
            HStack {
                Text("AD")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            }

            HStack {
                Text("Advertisement space")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                Text("320x50")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
            )
        }
        .padding(.horizontal)
    }

    private var buttonRow: some View {
        HStack(spacing: 15) {
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
            .tint(.gray)

            Button("Accept Quest") {
                if let quest = currentQuest {
                    questManager.acceptQuest(quest)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
}

struct AcceptQuestView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var questManager: QuestManager

    let quest: SideQuest

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Quest Accepted!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 15) {
                    Text(quest.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    if !quest.description.isEmpty {
                        Text(quest.description)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Label("\(quest.xpReward) XP", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                        Spacer()
                        Label("\(quest.coinReward) Coins", systemImage: "bitcoinsign.circle.fill")
                            .foregroundColor(.orange)
                    }
                    .fontWeight(.semibold)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)

                Spacer()

                Button("Complete Quest") {
                    questManager.completeQuest(quest)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("Active Quest")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct QuestHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var questManager: QuestManager

    var completedQuests: [SideQuest] {
        questManager.quests.filter { $0.timesCompleted > 0 }.sorted { quest1, quest2 in
            guard let date1 = quest1.lastCompletedDate, let date2 = quest2.lastCompletedDate else {
                return false
            }
            return date1 > date2
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()

                if completedQuests.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            summaryCard

                            ForEach(completedQuests) { quest in
                                questHistoryCard(quest)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Quest History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Completed Quests Yet")
                .font(.title2)
                .fontWeight(.bold)

            Text("Complete your first quest to start building your history!")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 15) {
            Text("Your Achievements")
                .font(.headline)
                .fontWeight(.bold)

            HStack(spacing: 30) {
                VStack {
                    Text("\(questManager.userProfile.completedQuests)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                VStack {
                    Text("\(questManager.userProfile.totalXP)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    Text("Total XP")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                VStack {
                    Text("\(questManager.userProfile.level)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    private func questHistoryCard(_ quest: SideQuest) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(quest.title)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                difficultyBadge(quest.difficulty)
            }

            if !quest.description.isEmpty {
                Text(quest.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            HStack {
                Image(systemName: "repeat.circle.fill")
                    .foregroundColor(.blue)
                Text("Completed \(quest.timesCompleted) time\(quest.timesCompleted == 1 ? "" : "s")")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            if let lastDate = quest.lastCompletedDate {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.gray)
                    Text("Last: \(formattedDate(lastDate))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Divider()

            ForEach(quest.completions.reversed()) { completion in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(formattedDate(completion.completedDate))
                        .font(.caption)
                        .foregroundColor(.gray)

                    Spacer()

                    Label("\(completion.earnedXP) XP", systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }

    private func difficultyBadge(_ difficulty: QuestDifficulty) -> some View {
        Text(difficulty.rawValue.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor(difficulty))
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    private func difficultyColor(_ difficulty: QuestDifficulty) -> Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy, hh:mm a"
        return formatter.string(from: date)
    }
}

struct HelpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    headerSection

                    howItWorksSection

                    featuresSection

                    tipsSection
                }
                .padding()
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("How to Use")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Welcome to Side Quest Bowl!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Never be bored again! Pick random side quests, earn XP, and level up.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("How It Works")
                .font(.headline)
                .fontWeight(.bold)

            stepItem(number: "1", icon: "plus.circle.fill", title: "Add Quests", description: "Tap the + button to add activities you'd like to do. Choose difficulty: Easy (10 XP), Medium (25 XP), or Hard (50 XP).")

            stepItem(number: "2", icon: "hand.tap.fill", title: "Pick a Quest", description: "Tap 'Pick Me a Side Quest!' and a random quest appears. Don't like it? Swipe left or right to pick another!")

            stepItem(number: "3", icon: "checkmark.circle.fill", title: "Complete Quest", description: "Accept the quest, complete it in real life, then tap 'Complete Quest' to earn XP and Quest Coins.")

            stepItem(number: "4", icon: "arrow.up.circle.fill", title: "Level Up", description: "Earn enough XP to level up! Each level requires more XP (Level × 100).")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Features")
                .font(.headline)
                .fontWeight(.bold)

            featureItem(icon: "slider.horizontal.3", color: .green, title: "Difficulty Filter", description: "Filter quests by Easy, Medium, or Hard before picking.")

            featureItem(icon: "star.fill", color: .yellow, title: "XP & Levels", description: "Track your progress and watch your level increase.")

            featureItem(icon: "bitcoinsign.circle.fill", color: .orange, title: "Quest Coins", description: "Earn coins for future customization features.")

            featureItem(icon: "arrow.2.squarepath", color: .purple, title: "Swipe to Change", description: "Swipe the quest card left or right to pick a different one.")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Pro Tips")
                .font(.headline)
                .fontWeight(.bold)

            tipItem(icon: "lightbulb.fill", tip: "Add a variety of quests - mix quick easy tasks with longer challenging ones.")

            tipItem(icon: "heart.fill", tip: "Use Side Quest Bowl when you're bored or procrastinating to stay productive.")

            tipItem(icon: "sparkles", tip: "Coming soon: Photo evidence, multiplayer, friends, and customization shop!")
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
        )
    }

    private func stepItem(number: String, icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)

                Text(number)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    private func featureItem(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    private func tipItem(icon: String, tip: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            Text(tip)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    MainBowlView()
        .environmentObject(QuestManager())
}
