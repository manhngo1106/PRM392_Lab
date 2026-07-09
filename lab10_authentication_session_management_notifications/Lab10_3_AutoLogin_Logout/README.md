# Lab10_3_AutoLogin_Logout

A Flutter project demonstrating session management, auto-login, and logout routing using `SharedPreferences`.

## How to Run

1. Navigate to the project folder:
   ```bash
   cd Lab10_3_AutoLogin_Logout
   ```
2. Retrieve packages:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Design Flow

- **SplashScreen**: The startup screen. It checks `SharedPreferences` for a stored login token.
  - If a token is found, it immediately forwards the user to the **HomeScreen** (Auto-login).
  - If no token is found, it routes to the **LoginScreen**.
- **LoginScreen**: Authenticates using the real DummyJSON API. Upon successful login, user details and the token are stored locally.
- **HomeScreen**: Restores and displays the user info. Offers a **Logout** button which clears all stored data and routes back to the Login screen.

## Test Account

- **Username**: `emilys`
- **Password**: `emilyspass`
