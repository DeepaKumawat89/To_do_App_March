# Flutter To-Do App (Cloud Firestore)

A complete Flutter mobile application to manage your daily tasks, powered by **Cloud Firestore** and **Firebase Authentication**.

## 🚀 Features

- **Authentication**: Secure Login and Signup using Firebase Auth.
- **Task Management**: Create, Read, Update, and Delete tasks.
- **Real-time Synchronization**: Powered by Cloud Firestore SDK.
- **Modern State Management**: Managed using the `Provider` package.
- **Premium UI**: Clean, modern Material 3 design with smooth interactions.
- **Persistence**: Maintains user session and auth state.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Database**: [Cloud Firestore](https://firebase.google.com/docs/firestore)
- **Auth**: [Firebase Authentication](https://firebase.google.com/docs/auth)

---

## 🔧 Firebase Setup Instructions

Follow these steps to connect your project to Firebase:

### 1. Create a Firebase Project
- Go to [Firebase Console](https://console.firebase.google.com/).
- Click **Add Project** and follow the steps.

### 2. Enable Authentication
- In the Firebase Console, go to **Authentication** > **Get Started**.
- Enable **Email/Password** sign-in provider.

### 3. Setup Cloud Firestore
- Go to **Firestore Database** > **Create database**.
- Select a location and start in **Test Mode**.
- **Rule Configuration** (Recommended for security):
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /users/{userId}/tasks/{taskId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```

### 4. Configure App
- Use the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli) to configure your app:
  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure
  ```
- This will generate `firebase_options.dart` and register your apps automatically.

---

## 📦 How to Build the APK

To generate a production-ready APK, run the following command in your terminal:

```bash
flutter build apk --release
```

The APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📂 Project Structure

```
lib/
├── models/       # Data models (Task)
├── providers/    # App state management (Auth, Tasks)
├── screens/      # UI Screens (Login, Home, etc.)
├── services/     # App services (Auth, Firestore)
├── utils/        # Constants and helpers
└── widgets/      # Reusable UI components
```

---

## 🤝 Contributing

Feel free to fork this project and submit PRs for any improvements!

## 📝 License

This project is open-source and available under the MIT License.
