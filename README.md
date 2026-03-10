# 🚀 TaskFlow &mdash; Organize Your Day Beautifully

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Material_3-7D5260?style=for-the-badge&logo=materialdesign&logoColor=white" />
</div>

---

**TaskFlow** is a premium, high-performance To-Do application built with **Flutter** and **Firebase**. It features a stunning modern UI, seamless real-time synchronization, and a smooth user experience designed to make productivity effortless and enjoyable.

## 🌟 Key Features

### 🔐 Secure Authentication
- **Multi-method Login**: Sign in securely with Email/Password or **Google One-Tap**.
- **Persistent Sessions**: Stay logged in across restarts with `shared_preferences`.
- **Password Recovery**: Effortless password reset functionality.

### 📝 Task Management
- **Real-time Sync**: Tasks are instantly updated across devices using **Cloud Firestore**.
- **CRUD Operations**: Create, read, update, and delete tasks with ease.
- **Intuitive UI**: Beautifully designed screens for adding and editing tasks.

### 🎨 Premium UI/UX
- **Dynamic Theming**: Support for **Light and Dark Modes** to suit your preference.
- **Responsive Design**: Built using `flutter_screenutil` for a perfect look on any screen size.
- **Interactive Navigation**: Featuring the sleek `water_drop_nav_bar`.
- **Delightful Animations**: Lottie animations on the Splash Screen and throughout the app.

---

## 🛠️ Built With

- **Framework**: [Flutter](https://flutter.dev) (v3.x)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Backend/Database**: [Cloud Firestore](https://firebase.google.com/docs/firestore)
- **Auth**: [Firebase Authentication](https://firebase.google.com/docs/auth) & [Google Sign-In](https://pub.dev/packages/google_sign_in)
- **Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **UI Components**: 
  - `water_drop_nav_bar` (Interactive Nav)
  - `lottie` (Vector Animations)
  - `flutter_screenutil` (Responsiveness)
  - `logger` (Clean Debugging)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- [Firebase account](https://console.firebase.google.com/) and a project created.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/taskflow.git
   cd taskflow
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
   - Run `flutterfire configure` and select your project.
   - This will generate `lib/firebase_options.dart`.

4. **Run the app**:
   ```bash
   flutter run
   ```

### 📦 Build Release APK
To generate a production-ready APK:
```bash
flutter build apk --release
```
The latest APK is saved at: `release/task_flow_release.apk`

---

## 📂 Project Architecture

```bash
lib/
├── models/       # Data blueprints (TaskModel)
├── providers/    # App states (Auth, Task, Theme)
├── screens/      # Feature-specific UI screens
├── services/     # API/Firebase logic (AuthService, TaskService)
├── utils/        # Constants, Themes, and Extensions
└── widgets/      # Reusable atomic UI components
```

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.

---

<div align="center">
  Made with ❤️ by Deepak Kumawat
</div>
