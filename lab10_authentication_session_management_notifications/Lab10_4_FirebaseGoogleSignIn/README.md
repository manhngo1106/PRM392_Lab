# Lab10_4_FirebaseGoogleSignIn

A Flutter project demonstrating integration of Google Sign-In with Firebase Authentication.

## Running in Fallback/Mock Mode (Immediate Verification)

If you compile and run this app out of the box, it automatically detects that no Firebase Configuration (`google-services.json` on Android or `GoogleService-Info.plist` on iOS) is present. 

To allow instant testing and grading of the UI, loading indicators, navigation flow, and logout behavior without crashing, the app gracefully falls back to a **Simulated Google Login**. 
A banner appears at the top: `Mock Mode: google-services.json not found. Simulation enabled.`

## Configuring Real Firebase Authentication

To verify with your own Firebase Project:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** and add the **Google** Sign-in provider.
3. Register your Android app:
   - Package name: `com.example.lab10_4_firebase_google_sign_in` (as defined in `android/app/build.gradle`).
   - Run the following command inside `android/` to get your SHA keys:
     ```bash
     ./gradlew signingReport
     ```
   - Copy the `SHA-1` key and paste it into the Firebase App Settings.
4. Download the `google-services.json` configuration file and place it inside `android/app/`.
5. Run the application:
   ```bash
   flutter pub get
   flutter run
   ```
