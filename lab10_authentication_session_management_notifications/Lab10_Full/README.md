# Lab10_Full

The final integrated Flutter application that combines mock/real REST API login, persistent sessions (`SharedPreferences`), Firebase Google Sign-In, and Local Notifications.

## How to Run

1. Navigate to the project folder:
   ```bash
   cd Lab10_Full
   ```
2. Retrieve packages:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Integrated Architectural Flow

1. **SplashScreen Startup Check**:
   - The app starts at `SplashScreen` which delays 2 seconds.
   - It checks if a Firebase user session is active. If yes, it routes straight to the **HomeScreen**.
   - Otherwise, it checks `SharedPreferences` for a stored DummyJSON API session token. If found, it routes to the **HomeScreen**.
   - If no sessions exist, it routes to the **LoginScreen**.
2. **LoginScreen Options**:
   - **DummyJSON REST API Authentication**: Form with username/password. On success, records profile details and the session token locally.
   - **Firebase Google Sign-In**: Tapping Google Sign-in processes authentications. Supports **Simulation fallback** if `google-services.json` is missing.
3. **Local Notifications Trigger**:
   - Instantly upon any successful login, the app requests notification permission and pushes a local notification banner: `"Login Successful! 🔐"` welcoming the user.
4. **HomeScreen**:
   - Restores user info dynamically based on whichever provider was used (DummyJSON API vs. Google Sign-In).
   - Displays avatar, name, email, auth provider label, and the raw session token / UID.
5. **Logout**:
   - Tapping Logout clears stored SharedPreferences, signs out of Firebase/Google, and routes back to the Login Screen, replacing the navigation stack.

## Test Accounts

### A. DummyJSON Credentials
- **Username**: `emilys`
- **Password**: `emilyspass`

- **Username**: `michaelw`
- **Password**: `michaelwpass`

### B. Google Credentials
- Runs in simulation fallback out-of-the-box (no config needed).
- Follow instructions in other READMEs to link your own Firebase project with SHA keys.
