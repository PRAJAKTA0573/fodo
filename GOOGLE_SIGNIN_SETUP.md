# Google Sign-In Setup Guide for FODO

This guide explains how to complete the Google Sign-In setup for your FODO app.

## ✅ What's Already Done

1. ✅ Added `google_sign_in` package to `pubspec.yaml`
2. ✅ Updated authentication service with Google Sign-In methods
3. ✅ Updated UI to use Google Sign-In button
4. ✅ Modified registration flow to work with Google authentication
5. ✅ Android build.gradle already has Google Services plugin configured

## 🔧 What You Need to Do

### 1. Firebase Console Configuration

#### A. Enable Google Sign-In in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **fodo-70bc6**
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Toggle **Enable**
6. Set the **Project support email** (your email)
7. Click **Save**

#### B. Add SHA-1 Certificate Fingerprint (for Android)

You need to add your app's SHA-1 fingerprint to Firebase:

**Get your SHA-1 fingerprint:**

```bash
# For debug builds (development)
cd /Users/abhishekshelar/StudioProjects/fodo/android
./gradlew signingReport
```

Or use keytool:
```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Add to Firebase:**
1. Copy the SHA-1 fingerprint from the output
2. In Firebase Console → Project Settings → General
3. Scroll to "Your apps" section
4. Click on your Android app
5. Click "Add fingerprint"
6. Paste the SHA-1 fingerprint
7. Click Save

**For release builds:**
- You'll need to add the SHA-1 from your release keystore as well
- Follow the same process with your release keystore file

### 2. Download Updated Configuration Files

After adding SHA-1 fingerprint:

**For Android:**
1. In Firebase Console → Project Settings → General
2. Download the updated `google-services.json`
3. Replace the file at: `android/app/google-services.json`

**For iOS:**
1. Download the updated `GoogleService-Info.plist` 
2. Check if it contains `REVERSED_CLIENT_ID` key
3. If it doesn't, you may need to add it manually or re-download from Firebase

### 3. iOS Configuration

#### A. Add URL Scheme to Info.plist

You need to add the REVERSED_CLIENT_ID to your iOS `Info.plist`:

1. Open `GoogleService-Info.plist` in Firebase Console downloads
2. Find the `REVERSED_CLIENT_ID` value (looks like: `com.googleusercontent.apps.XXXXXX`)
3. Add this to `ios/Runner/Info.plist` before the closing `</dict>`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

**Example:**
If your REVERSED_CLIENT_ID is `com.googleusercontent.apps.192098989997-abc123xyz`, use that exact string.

#### B. Update GoogleService-Info.plist

Make sure your `ios/Runner/GoogleService-Info.plist` has the `REVERSED_CLIENT_ID` key. If not:

1. Re-download from Firebase Console
2. Replace `ios/Runner/GoogleService-Info.plist`

### 4. Test Your Setup

After completing the above steps:

```bash
# Clean the build
flutter clean

# Get dependencies
flutter pub get

# For Android
flutter run

# For iOS
flutter run -d ios
```

## 🎯 Testing Google Sign-In

1. Launch the app
2. You should see "Sign in with Google" button on the login screen
3. Click the button
4. Select/enter your Google account
5. Grant permissions
6. **First-time users**: You'll be redirected to select user type (Donor/NGO) and complete profile
7. **Returning users**: You'll be logged in directly to your dashboard

## 📝 Important Notes

### User Flow
- **New Users**: Google Sign-In → Select User Type (Donor/NGO) → Complete Profile → Dashboard
- **Existing Users**: Google Sign-In → Dashboard (automatic login)

### Data Collection
After Google Sign-In, the app collects:
- **Donors**: Phone number, organization (optional), address, city, state, pincode
- **NGOs**: NGO name, registration number, phone, contact person details, address

### No Email/Password Required
- Email comes from Google account (pre-verified)
- No password needed (Google handles authentication)
- More secure and easier for users

## 🔍 Troubleshooting

### Android Issues

**"Google Sign-In failed" or "Error 10"**
- Check that SHA-1 fingerprint is added to Firebase
- Ensure `google-services.json` is updated
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

**"Developer Error" or "Error 12500"**
- Wrong SHA-1 fingerprint
- Verify you're using the correct keystore (debug vs release)

### iOS Issues

**"Sign in was cancelled"**
- Check that URL scheme (REVERSED_CLIENT_ID) is added to Info.plist
- Verify GoogleService-Info.plist is present and correct

**"Invalid client ID"**
- Ensure bundle identifier matches in Firebase Console
- Bundle ID should be: `com.example.fodo`

## 🚀 Production Deployment

Before releasing to Google Play Store or App Store:

1. **Android**: Add release keystore SHA-1 to Firebase
2. **iOS**: Ensure all provisioning profiles are configured
3. **Both**: Test Google Sign-In with release builds
4. Update `applicationId` (Android) and `BUNDLE_ID` (iOS) from `com.example.fodo` to your actual app ID

## 📚 Additional Resources

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Firebase Authentication](https://firebase.google.com/docs/auth/flutter/start)
- [Google Sign-In Setup](https://firebase.google.com/docs/auth/flutter/federated-auth)

## ✅ Verification Checklist

- [ ] Google Sign-In enabled in Firebase Console
- [ ] SHA-1 fingerprint added to Firebase (Android)
- [ ] google-services.json updated (Android)
- [ ] GoogleService-Info.plist updated (iOS)
- [ ] REVERSED_CLIENT_ID added to Info.plist (iOS)
- [ ] `flutter pub get` executed
- [ ] App tested on real device
- [ ] New user flow tested (registration)
- [ ] Existing user flow tested (login)

---

**Current Project**: fodo-70bc6  
**Bundle ID**: com.example.fodo  
**Last Updated**: October 2025
