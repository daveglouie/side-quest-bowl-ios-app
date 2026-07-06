# Side Quest Bowl iOS App

A gamified iOS app that randomly picks side quests and activities for you to complete. Earn XP and Quest Coins by completing quests, level up, and track your progress!

## 🎥 Watch the Demo



https://github.com/user-attachments/assets/d62420df-9fae-482f-a8a5-602f00d4af4f



---

## What is Side Quest Bowl?

Side Quest Bowl helps you combat boredom by:
- Storing a collection of side quests/activities you'd like to do
- Randomly picking a quest for you when you're bored
- Gamifying completion with XP, coins, and levels
- Filtering quests by difficulty (Easy/Medium/Hard)
- Tracking your progress and completed quests

**Current Features (Phase 1 - MVP):**
- 🎲 Random quest picker with difficulty filtering
- 👆 **Swipe gesture** - Swipe left/right to pick different quests
- ➕ Add custom side quests
- 📊 XP and Quest Coins reward system
- 🎯 Level progression system
- 💾 Persistent storage (quests saved between sessions)
- 🎨 Beautiful bowl graphic with folded paper design
- 📺 **Banner ads** - Sponsored ads integrated with quests
- ❓ **Help system** - Built-in tutorial for new users
- 🎯 **Starter quests** - Three pre-loaded quests to get started

**Planned Features (Future Phases):**
- 📸 Photo evidence for quest completion
- 🤖 AI difficulty assessment
- 👥 Multiplayer lobbies and friends system
- 🛍️ Customization shop (bowl skins, paper designs)
- 📱 Social sharing and quest suggestions
- ⏱️ Timed group quests with photo submission

## Prerequisites

- macOS with Xcode installed
- iOS Simulator (comes with Xcode)
- iOS 17.0 or later

## Project Structure

The app is currently built as a single-file SwiftUI application for simplicity. Here's how the code is organized:

```
iOSAppHelloWorld/
├── SideQuestBowl.xcodeproj/       # Xcode project file
├── SideQuestBowlComplete.swift     # Main app file (all code in one place)
├── Assets.xcassets/                # Images and icons
│   └── AppIcon.appiconset/        # App icon (bowl with quest cards)
├── Info.plist                      # App configuration
└── README.md                       # This file
```

### Code Architecture Explained

The `SideQuestBowlComplete.swift` file contains everything organized into sections:

#### 1. **Models** (Data Structures)
```swift
- QuestDifficulty (enum)
  └─ Defines Easy/Medium/Hard difficulty levels
  └─ Contains XP and coin reward amounts

- QuestAd (enum)
  └─ Defines sponsored ads (rileysDogWalking, ninjaCreami, stretchLab)
  └─ Properties: sponsorName, tagline, iconName, colors, etc.
  └─ Encapsulates all ad branding and styling

- SideQuest (struct)
  └─ Represents a single quest
  └─ Properties: title, description, difficulty, completion status
  └─ private(set) sponsoredAd: QuestAd? - Read-only ad property
  └─ Users cannot create or edit ads (enforced by private setter)

- UserProfile (struct)
  └─ Tracks player progress
  └─ Properties: totalXP, questCoins, level, completedQuests
  └─ Functions: addXP(), addCoins(), levelUp logic
```

#### 2. **ViewModel** (Business Logic)
```swift
- QuestManager (class)
  └─ Manages all quests and user profile
  └─ Key functions:
     • addQuest() - Saves a new quest
     • getRandomQuest() - Picks a random quest (with optional difficulty filter)
     • completeQuest() - Awards XP/coins and marks quest complete
     • addDefaultQuestsIfNeeded() - Adds 3 starter quests on first launch
     • save/load functions - Persists data using UserDefaults
  └─ Anti-repeat logic: Ensures you don't get the same quest twice in a row
```

#### 3. **Views** (User Interface)
```swift
- MainBowlView
  └─ The home screen with bowl graphic
  └─ Shows user stats (level, XP, coins)
  └─ "Pick Me a Side Quest!" button
  └─ Difficulty filter buttons (Any/Easy/Medium/Hard)
  └─ Toolbar: Help (?) button and Add Quest (+) button

- AddQuestSheet
  └─ Form to create new quests
  └─ Input fields: title, description, difficulty selector
  └─ Users cannot add or edit ads (enforced by private setter)

- QuestPickerSheet
  └─ Displays randomly selected quest on paper graphic
  └─ Swipe gesture support (left/right to change quests)
  └─ Animated card transitions
  └─ Banner ad display (sponsored or generic placeholder)
  └─ Two buttons: "Cancel" | "Accept Quest"
  └─ Anti-repeat logic prevents same quest appearing twice

- AcceptQuestView
  └─ Shown after accepting a quest
  └─ Displays quest details
  └─ "Complete Quest" button (simplified for Phase 1)

- HelpView
  └─ Comprehensive onboarding guide
  └─ Sections: Welcome, How It Works, Features, Pro Tips
  └─ Step-by-step instructions with icons
```

#### 4. **App Entry Point**
```swift
- SideQuestBowlApp (@main)
  └─ Creates QuestManager instance
  └─ Launches MainBowlView as root view
  └─ Injects QuestManager as environment object (makes it available to all views)
```

### How Data Flows

1. **Adding a Quest:**
   - User opens AddQuestSheet → fills in details → taps "Add Quest"
   - Quest is created → QuestManager.addQuest() saves it
   - Data persisted to UserDefaults

2. **Picking a Quest:**
   - User taps "Pick Me a Side Quest!" → QuestPickerSheet appears
   - QuestManager.getRandomQuest() picks from available quests
   - Quest displayed on paper graphic

3. **Completing a Quest:**
   - User accepts quest → shown in AcceptQuestView
   - Taps "Complete Quest" → QuestManager.completeQuest() called
   - XP and coins added → level updated → data saved

### Key SwiftUI Concepts Used

- **@StateObject**: Creates and owns the QuestManager instance
- **@EnvironmentObject**: Shares QuestManager across all views
- **@Published**: Makes properties trigger UI updates when changed
- **@State**: Local view state (like showing/hiding sheets)
- **@Environment(\.dismiss)**: Closes modal sheets
- **NavigationView**: Provides navigation bar and transitions
- **Sheet modifiers**: Presents modal screens
- **UserDefaults**: Saves data persistently

## Running the App

### Option 1: Using Xcode (Recommended for Simulator)

1. Open the project in Xcode:
   ```bash
   open SideQuestBowl.xcodeproj
   ```

2. Select a simulator from the device dropdown (e.g., "iPhone 17 Pro")

3. Click the Play button (▶️) or press `Cmd + R`

### Option 2: Using Command Line (Simulator)

#### Build the app:
```bash
xcodebuild -project SideQuestBowl.xcodeproj \
  -scheme SideQuestBowl \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

#### Launch the simulator:
```bash
open -a Simulator
```

#### Install the app on the simulator:
```bash
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/SideQuestBowl-*/Build/Products/Debug-iphonesimulator/SideQuestBowl.app
```

#### Run the app:
```bash
xcrun simctl launch booted com.example.SideQuestBowl
```

### Quick Run Script (All-in-One)

```bash
# Build, install, and run in one go
xcodebuild -project SideQuestBowl.xcodeproj \
  -scheme SideQuestBowl \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build && \
open -a Simulator && \
sleep 3 && \
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/SideQuestBowl-*/Build/Products/Debug-iphonesimulator/SideQuestBowl.app && \
xcrun simctl launch booted com.example.SideQuestBowl
```

## Installing on a Real iPhone

You can install Side Quest Bowl on your physical iPhone using any of these methods:

### Method 1: Direct Install via Xcode (Easiest - Free)

**Requirements:**
- Lightning or USB-C cable to connect your iPhone to your Mac
- Your iPhone and Mac logged into the same Apple ID
- No paid Apple Developer account needed!

**Steps:**

1. **Connect your iPhone** to your Mac using a cable

2. **Trust the computer** on your iPhone when the prompt appears

3. **Open the project in Xcode:**
   ```bash
   open SideQuestBowl.xcodeproj
   ```

4. **Configure signing:**
   - In Xcode, select the project in the navigator (top item)
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team (this will be your Apple ID email)
   - The bundle identifier may automatically change to include your team ID

5. **Select your iPhone as the destination:**
   - At the top of Xcode, click the device dropdown (next to the Play button)
   - Your iPhone should appear in the list
   - Select it

6. **Build and run:**
   - Click the Play button (▶️) or press `Cmd + R`
   - Xcode will build and install the app on your iPhone

7. **Trust the developer certificate on your iPhone:**
   - On your iPhone, go to: **Settings → General → VPN & Device Management**
   - Tap your Apple ID under "Developer App"
   - Tap **"Trust [Your Apple ID]"**
   - Confirm by tapping **"Trust"**

8. **Launch the app** from your home screen!

**Note:** With a free Apple Developer account, the app will expire after **7 days** and you'll need to reinstall it. This is a limitation Apple imposes on free accounts.

---

### Method 2: Command Line Install (Advanced)

**Steps:**

1. **Connect your iPhone and find its name:**
   ```bash
   xcrun xctrace list devices
   ```
   Look for your iPhone name in the output (e.g., "David's iPhone")

2. **Build for your device:**
   ```bash
   xcodebuild -scheme SideQuestBowl \
     -destination 'platform=iOS,name=YOUR_IPHONE_NAME' \
     clean build
   ```
   Replace `YOUR_IPHONE_NAME` with your actual device name

3. **The app will be installed automatically** during the build process

4. **Trust the developer certificate** (see step 7 above)

---

### Method 3: Paid Apple Developer Account ($99/year)

If you have a paid Apple Developer Program membership:

**Benefits:**
- Apps stay installed for **1 year** instead of 7 days
- Can distribute via **TestFlight** to up to 10,000 testers
- Can publish to the **App Store**
- Can use advanced capabilities (push notifications, Apple Pay, etc.)

**Steps:**
1. Enroll at https://developer.apple.com/programs/
2. In Xcode's "Signing & Capabilities", select your paid developer team
3. Follow the same steps as Method 1
4. Your app will now stay installed for a full year

---

### Method 4: TestFlight (Requires Paid Account)

**For distributing to friends or beta testers:**

1. Archive the app in Xcode:
   - Product → Archive
   
2. Upload to App Store Connect:
   - Click "Distribute App"
   - Select "App Store Connect"
   - Follow the prompts

3. Add testers in App Store Connect:
   - Go to https://appstoreconnect.apple.com
   - Select your app → TestFlight
   - Add internal or external testers by email

4. Testers install TestFlight app and accept invitation

---

### Troubleshooting Real Device Installation

**"Failed to verify code signature"**
- Go to Xcode → Settings → Accounts
- Ensure your Apple ID is signed in
- Click "Download Manual Profiles"

**"Developer Mode required"**
- On iOS 16+, go to Settings → Privacy & Security → Developer Mode
- Enable Developer Mode and restart your iPhone

**"Could not launch [app]"**
- Ensure you've trusted the developer certificate in Settings
- Try unplugging and reconnecting your iPhone
- Clean build folder: Product → Clean Build Folder

**App crashes immediately on launch**
- Check Xcode console for error messages
- Ensure your iPhone meets minimum iOS version (iOS 17.0+)

**"Provisioning profile doesn't match"**
- In Signing & Capabilities, try toggling "Automatically manage signing" off and on
- Or manually select a different provisioning profile

---

## Using the App

### First Launch
The app comes with **3 starter quests** to try immediately:
- **"Walk the dog"** (Medium) - with Riley's Dog Walking ad
- **"Prep Ninja Creami"** (Easy) - with Ninja Creami ad  
- **"Stretch"** (Easy) - with StretchLab ad

### Getting Help
Tap the **?** button in the top right to see the built-in help guide with:
- How the app works (4-step guide)
- All features explained
- Pro tips for getting the most out of the app

### Step 1: Add Some Quests
1. Tap the `+` button in the top right
2. Enter a quest title (e.g., "Take a 30-minute walk")
3. Optionally add a description
4. Choose difficulty (Easy/Medium/Hard)
5. Tap "Add Quest"

**Note:** User-created quests show a generic ad placeholder. Only default/special quests have branded ads.

**Example Quests to Add:**
- Easy: "Do 10 pushups", "Read for 15 minutes", "Call a friend"
- Medium: "Cook a new recipe", "Organize a closet", "Learn a new skill for 1 hour"
- Hard: "Run 5K", "Complete a creative project", "Deep clean entire apartment"

### Step 2: Pick a Quest
1. On the main screen, optionally select a difficulty filter (Any/Easy/Medium/Hard)
2. Tap "Pick Me a Side Quest!"
3. A random quest appears on a paper graphic with a banner ad
4. **Swipe left or right** to pick a different quest (won't repeat the same one!)
5. Or tap "Accept Quest" if you like it, or "Cancel" to close

**Swipe Tip:** The quest card rotates and flies off when you swipe, and a new one slides in from the opposite side.

### Step 3: Complete Quest
1. After accepting, complete the quest in real life
2. Tap "Complete Quest" (photo evidence coming in Phase 2!)
3. Earn XP and Quest Coins
4. Watch your level increase!

## Useful Simulator Commands

### List available simulators:
```bash
xcrun simctl list devices available
```

### Boot a specific simulator:
```bash
xcrun simctl boot "iPhone 17 Pro"
```

### Shutdown a simulator:
```bash
xcrun simctl shutdown "iPhone 17 Pro"
```

### Uninstall the app:
```bash
xcrun simctl uninstall booted com.example.SideQuestBowl
```

### Take a screenshot:
```bash
xcrun simctl io booted screenshot screenshot.png
```

### Reset app data (clear all quests and progress):
```bash
xcrun simctl uninstall booted com.example.SideQuestBowl
```

## Modifying the App

### Adding New Sponsored Ads

Ads are defined in the `QuestAd` enum. To add a new sponsored ad:

1. Add a new case to the enum:
```swift
enum QuestAd: String, Codable {
    case rileysDogWalking
    case ninjaCreami
    case stretchLab
    case yourNewAd  // Add here
}
```

2. Implement the required properties in each computed property:
```swift
var sponsorName: String {
    case .yourNewAd: return "Your Brand Name"
}
var tagline: String {
    case .yourNewAd: return "Your tagline here"
}
// ... and so on for iconName, ctaText, gradientColors, accentColor, shadowColor
```

3. Assign the ad to a default quest or create a new one:
```swift
SideQuest(
    title: "Your Quest Title",
    difficulty: .medium,
    sponsoredAd: .yourNewAd
)
```

**Important:** Users cannot create or modify ads. The `sponsoredAd` property has a private setter, ensuring only app code can assign ads.

### Changing XP and Coin Rewards

Edit the `QuestDifficulty` enum in `SideQuestBowlComplete.swift`:

```swift
var xpReward: Int {
    switch self {
    case .easy: return 10      // Change these values
    case .medium: return 25
    case .hard: return 50
    }
}
```

### Changing Level-Up Requirements

Edit the `UserProfile` struct:

```swift
var xpForNextLevel: Int {
    level * 100  // Change formula (e.g., level * 150 for slower progression)
}
```

### Customizing the Bowl Colors

Edit `MainBowlView` in the `bowlGraphic` section:

```swift
Circle()
    .fill(
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]),
            // Change colors: .purple, .green, .red, etc.
            startPoint: .top,
            endPoint: .bottom
        )
    )
```

### Adjusting Default Quests

Edit the `addDefaultQuestsIfNeeded()` function in `QuestManager`:

```swift
let defaultQuests = [
    SideQuest(title: "Walk the dog", difficulty: .medium, sponsoredAd: .rileysDogWalking),
    SideQuest(title: "Prep Ninja Creami", difficulty: .easy, sponsoredAd: .ninjaCreami),
    SideQuest(title: "Stretch", difficulty: .easy, sponsoredAd: .stretchLab),
    // Add more default quests here
]
```

## Troubleshooting

### "No such file or directory" when installing
The build path may have changed. Find the correct path:
```bash
find ~/Library/Developer/Xcode/DerivedData -name "SideQuestBowl.app" -path "*/Debug-iphonesimulator/*"
```

### Simulator not responding
Try resetting the simulator:
```bash
xcrun simctl shutdown all
xcrun simctl erase all
```

### Build errors
Clean the build folder:
```bash
xcodebuild -project SideQuestBowl.xcodeproj -scheme SideQuestBowl clean
```

### App won't launch
Check if simulator is booted:
```bash
xcrun simctl list devices | grep Booted
```

## Development Roadmap

### Phase 1: MVP ✅ (Current)
- ✅ Basic quest management
- ✅ Random picker with difficulty filter
- ✅ Swipe gesture to change quests
- ✅ Anti-repeat logic (no duplicate quests in a row)
- ✅ XP/coins/levels system
- ✅ Local data persistence
- ✅ Starter quests (3 pre-loaded quests)
- ✅ Banner ad system with sponsored ads
- ✅ Help system for new users
- ✅ Professional UI with animations

### Phase 2: Evidence & AI (Planned)
- Camera integration for photo evidence
- AI difficulty assessment API integration
- Photo gallery for completed quests
- Quest validation system

### Phase 3: Social & Multiplayer (Planned)
- User accounts and authentication
- Friends system
- Multiplayer lobby codes
- Timed group quests with photo submission
- Direct messaging

### Phase 4: Customization & Community (Planned)
- Shop for bowl skins and paper designs
- Theme customization
- Quest sharing and suggestions
- Social feed
- Leaderboards

## Technical Details

- **Language**: Swift 5.0
- **Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: UserDefaults (will migrate to Core Data or CloudKit in future)
- **Bundle ID**: com.example.SideQuestBowl
- **Monetization**: Banner ad system (ready for ad network integration)

## Key Technical Features

### Ad System Architecture
- **Separation of Concerns**: Ads are separate from user-created content
- **Type-Safe Ads**: `QuestAd` enum ensures compile-time safety
- **User Protection**: Users cannot create or edit ads (enforced via `private(set)`)
- **Easy Integration**: Ready to connect to AdMob, Facebook Ads, or custom networks
- **Branded vs Generic**: Shows branded ads for special quests, placeholder for user quests

### Gesture-Based UX
- **Drag Gestures**: SwiftUI DragGesture API for swipe-to-change
- **Spring Animations**: Natural feeling card transitions
- **Visual Feedback**: Cards rotate, scale, and fade during interactions
- **No Repeat Logic**: Smart randomization prevents consecutive duplicates

### Data Flow
- **@Published Properties**: Reactive UI updates via Combine framework
- **Environment Objects**: Shared state across view hierarchy
- **UserDefaults Persistence**: Automatic save/load for quests and profile
- **Codable Models**: Easy serialization/deserialization

## Resources

- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [iOS Simulator Guide](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)
- [SwiftUI by Example](https://www.hackingwithswift.com/quick-start/swiftui)

## License

This is a personal project. Feel free to use and modify as you wish!
