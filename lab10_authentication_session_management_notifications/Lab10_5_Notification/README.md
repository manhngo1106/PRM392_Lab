# Lab10_5_Notification

A Flutter project demonstrating integration of Local Notifications, including asking for user permission dynamically on Android 13+ (API 33+).

## How to Run

1. Navigate to the project folder:
   ```bash
   cd Lab10_5_Notification
   ```
2. Retrieve packages:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Implementation Highlights

- **OS Notification Permissions**: Configured for Android 13+ utilizing `POST_NOTIFICATIONS` permission.
- **Dynamic Check & Request**: The app checks the state of permission immediately and prompts the user to grant permission when clicking "Request OS Permission".
- **Local Trigger**: Tapping "Trigger Test Notification" instantly fires a high priority local notification showing an alert banner.
