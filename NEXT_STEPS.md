# 🚀 Next Steps - Google Sign-In Setup

## Immediate Actions Required

### 1️⃣ Firebase Console Setup (5 minutes)

**Enable Google Sign-In:**
```
1. Go to: https://console.firebase.google.com/
2. Select project: fodo-70bc6
3. Navigate to: Authentication → Sign-in method
4. Click: Google → Enable → Save
5. Set your email as support email
```

### 2️⃣ Get SHA-1 Fingerprint for Android (2 minutes)

**Run this command:**
```bash
cd /Users/abhishekshelar/StudioProjects/fodo/android
./gradlew signingReport
```

**Or use keytool:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Look for:** `SHA1: XX:XX:XX:...`

### 3️⃣ Add SHA-1 to Firebase (2 minutes)

```
1. Copy the SHA-1 fingerprint
2. Firebase Console → Project Settings → General
3. Scroll to "Your apps" → Android app
4. Click "Add fingerprint"
5. Paste SHA-1 → Save
```

### 4️⃣ Download Updated Config Files (2 minutes)

**Android:**
```
1. Firebase Console → Project Settings → General
2. Under Android app → Download google-services.json
3. Replace: /Users/abhishekshelar/StudioProjects/fodo/android/app/google-services.json
```

**iOS:**
```
1. Firebase Console → Project Settings → General
2. Under iOS app → Download GoogleService-Info.plist
3. Replace: /Users/abhishekshelar/StudioProjects/fodo/ios/Runner/GoogleService-Info.plist
```

### 5️⃣ iOS URL Scheme Setup (3 minutes)

**Find REVERSED_CLIENT_ID:**
- Open the downloaded `GoogleService-Info.plist`
- Find key: `REVERSED_CLIENT_ID`
- Value looks like: `com.googleusercontent.apps.XXXXXX-YYYYYY`

**Add to Info.plist:**
```bash
# Open the file
open /Users/abhishekshelar/StudioProjects/fodo/ios/Runner/Info.plist
```

**Add before `</dict>`:**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR-REVERSED-CLIENT-ID-HERE</string>
        </array>
    </dict>
</array>
```

### 6️⃣ Test Your Implementation (5 minutes)

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run on Android
flutter run

# Or run on iOS
flutter run -d ios
```

**Test checklist:**
- [ ] App launches successfully
- [ ] "Sign in with Google" button appears
- [ ] Clicking button opens Google sign-in
- [ ] Can select Google account
- [ ] New user → redirected to profile completion
- [ ] Existing user → goes to dashboard

---

## 📖 Full Documentation

For detailed instructions and troubleshooting:
- **Setup Guide**: `GOOGLE_SIGNIN_SETUP.md`
- **Migration Details**: `GOOGLE_SIGNIN_MIGRATION.md`

## ⏱️ Total Time Needed: ~15-20 minutes

## 🆘 Quick Help

**Can't find SHA-1?**
```bash
# Make sure you're in the right directory
cd /Users/abhishekshelar/StudioProjects/fodo/android
./gradlew signingReport | grep SHA1
```

**Google Sign-In not working?**
1. Check SHA-1 is correct in Firebase
2. Verify google-services.json is updated
3. Clean and rebuild: `flutter clean && flutter pub get`

**iOS issues?**
1. Verify REVERSED_CLIENT_ID is in Info.plist
2. Check bundle ID matches: `com.example.fodo`
3. Ensure GoogleService-Info.plist is latest version

---

**Need help?** Check the troubleshooting section in `GOOGLE_SIGNIN_SETUP.md`
