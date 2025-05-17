# Firebase Setup for VenaCura App

This document contains instructions for setting up Firebase authentication with Google Sign-In for the VenaCura app.

## Prerequisites

- Flutter SDK
- Firebase account
- Google Cloud Platform account

## Setup Steps

### 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name your project (e.g., "VenaCura")
4. Follow the setup wizard
5. Once created, you'll be directed to the project dashboard

### 2. Register iOS App

1. In the Firebase project dashboard, click "iOS" to add an iOS app
2. Enter the iOS bundle ID: `io.omardahleh.cvidetect`
3. Enter app nickname (e.g., "VenaCura iOS")
4. Register the app

### 3. Download Configuration File

1. Download the `GoogleService-Info.plist` file
2. Place it in the `ios/Runner` directory of your Flutter project

### 4. Update Firebase Configuration

1. Open `lib/firebase_options.dart`
2. Replace the placeholder values with actual values from your `GoogleService-Info.plist`:
   ```dart
   static const FirebaseOptions ios = FirebaseOptions(
     apiKey: 'ACTUAL_API_KEY',
     appId: 'ACTUAL_APP_ID',
     messagingSenderId: 'ACTUAL_MESSAGING_SENDER_ID',
     projectId: 'ACTUAL_PROJECT_ID',
     storageBucket: 'ACTUAL_STORAGE_BUCKET',
     iosBundleId: 'io.omardahleh.cvidetect',
   );
   ```

### 5. Set Up Google Sign-In

1. Go to the [Firebase Console](https://console.firebase.google.com/) > Authentication
2. Enable Google Sign-In method
3. Add the SHA-1 fingerprint for Android (if needed)
4. Update the `Info.plist` file with the correct `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>ACTUAL_REVERSED_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```

### 6. Run pod install

```bash
cd ios
pod install
```

### 7. Build and Run

```bash
flutter run
```

## Troubleshooting

- If you encounter issues with Google Sign-In, ensure your device or simulator is properly set up with Google accounts.
- For iOS simulators, you may need to add Google accounts in Settings.
- For real devices, ensure you're signed in to a Google account.
- Check the Firebase Console logs for authentication errors.

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In Documentation](https://pub.dev/packages/google_sign_in) 