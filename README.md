# 💎 Time Gem

**Time Gem** is an open-source, **agentic AI** application that intelligently manages your time. Powered by **Gemini 3**, it bridges the gap between your task list and your calendar, negotiating your schedule for you.

Built with 💙 using **Flutter** and **Google's Antigravity**.

---

## 🚀 Features

*   **⚡ Agentic Scheduling**: Gemini 3 analyzes your tasks, estimates durations, and finds the perfect slot in your Google Calendar.
*   **🧠 Intelligent Context**: Understands your working hours, preferences, and existing constraints.
*   **📅 Seamless Integration**: Two-way sync with Google Calendar.
*   **🏎️ Built for Speed**: Native performance with Flutter.

---

## 🎥 Look Inside

| 1. The Onboarding Experience | 2. Time Gem in Action |
| :---: | :---: |
| See how Time Gem learns about your preferences and connects to your digital life. | Watch Gemini 3 organize a chaotic to-do list into a perfectly structured day. |
| <img src="./readme_assets/onboarding.gif" width="400"/> | <img src="./readme_assets/app.gif" width="400"/> |

---

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **AI Model**: [Gemini 3](https://deepmind.google/technologies/gemini/) (via Vertex AI in Firebase)
*   **Backend / Auth**: [Firebase Authentication](https://firebase.google.com/products/auth) & [Vertex AI](https://firebase.google.com/products/vertex-ai)
*   **Local Storage**: [SQLite](https://pub.dev/packages/sqflite) & [Shared Preferences](https://pub.dev/packages/shared_preferences)
*   **Integrations**: [Google Calendar API](https://developers.google.com/calendar)

---

## 💻 Try it Yourself

Want to run Time Gem on your own device? Follow these steps to set up your environment.

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/time_gem.git
cd time_gem
```

### 2. Set up Firebase
1.  Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  **Add an Android App**:
    *   Package name: `com.alfredobautista.timegem`
    *   Download `google-services.json` and place it in `android/app/`.
3.  **Add an iOS App** (Optional):
    *   Bundle ID: `com.alfredobautista.timegem`
    *   Download `GoogleService-Info.plist` and place it in `ios/Runner/`.
4.  **Enable Authentication**:
    *   Go to **Build** > **Authentication** > **Get Started**.
    *   Enable **Google** as a Sign-in provider.
5.  **Enable Vertex AI**:
    *   Go to **Build** > **Vertex AI in Firebase**.
    *   Click **Get Started** / **Enable API**.

### 3. Set up Google Calendar API
1.  Go to the [Google Cloud Console](https://console.cloud.google.com/) (select your Firebase project).
2.  Navigate to **APIs & Services** > **Library**.
3.  Search for **Google Calendar API** and enable it.
4.  Navigate to **APIs & Services** > **OAuth consent screen**:
    *   Set up the screen (External or Internal).
    *   Add the scope: `https://www.googleapis.com/auth/calendar` and `https://www.googleapis.com/auth/calendar.events`.
    *   Add your test user email addresses.

### 4. Run the App
```bash
flutter pub get
flutter run
```

---

## 🙌 Acknowledgments

A huge thank you for making this project possible!

*   **Google Developer Experts (GDE) - AI DevRel Team**: For the incredible support and resources.
*   **#AISprintH2**: Thank you for the access to Gemini credits that powered the intelligence of Time Gem! 🚀
*   **Antigravity**: This entire application was developed using Google's Antigravity agentic coding environment. The experience was truly next-level.

---

*Built with passion by Alfredo Bautista.*