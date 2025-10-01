# 🚨 CRITICAL: Fix Google Sign-In Error

## ✅ Issue Fixed: Image Loading Error
The Google logo image error has been fixed. The app now uses a Material icon instead.

## ⚠️ ACTION REQUIRED: Add SHA-1 to Firebase

**Error:** `ApiException: 10` - This means Google Sign-In is not configured in Firebase.

### Your SHA-1 Fingerprint:
```
6B:9C:BC:D2:07:C7:AC:1D:FB:31:24:26:43:38:A3:6F:8A:88:7E:C1
```

### Steps to Fix (5 minutes):

#### 1. Go to Firebase Console
```
https://console.firebase.google.com/
```

#### 2. Select Your Project
- Project: **fodo-70bc6**

#### 3. Enable Google Sign-In
1. Go to **Authentication** → **Sign-in method**
2. Click on **Google**
3. Toggle **Enable**
4. Set your email as the support email
5. Click **Save**

#### 4. Add SHA-1 Fingerprint
1. Still in Firebase Console, go to **Project Settings** (⚙️ gear icon)
2. Scroll down to **Your apps**
3. Find your Android app (`com.example.fodo`)
4. Click **Add fingerprint** button
5. Paste this SHA-1:
   ```
   6B:9C:BC:D2:07:C7:AC:1D:FB:31:24:26:43:38:A3:6F:8A:88:7E:C1
   ```
6. Click **Save**

#### 5. Download Updated google-services.json
1. In the same screen (Project Settings → Your apps → Android)
2. Click **Download google-services.json**
3. Replace the file at:
   ```
   /Users/abhishekshelar/StudioProjects/fodo/android/app/google-services.json
   ```

#### 6. Rebuild and Test
```bash
# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🎯 What to Expect After Fix

1. Open the app
2. Click "Sign in with Google"
3. Select your Google account
4. First time: Complete your profile
5. Success! 🎉

---

## 🔍 Troubleshooting

**Still getting error after adding SHA-1?**
- Wait 1-2 minutes for Firebase to sync
- Make sure you downloaded the new `google-services.json`
- Run `flutter clean && flutter pub get`
- Restart your device/emulator

**Can't find Project Settings?**
- Look for the ⚙️ gear icon next to "Project Overview" at the top left

**Need the SHA-1 again?**
```bash
cd /Users/abhishekshelar/StudioProjects/fodo/android
./gradlew signingReport | grep SHA1 | head -1
```

---

## 📝 Summary of Changes Made

✅ Fixed image loading error (replaced network image with icon)
✅ Extracted your SHA-1 fingerprint
⏳ **YOU NEED TO:** Add SHA-1 to Firebase (5 minutes)

**Your SHA-1 (copy this):**
```
6B:9C:BC:D2:07:C7:AC:1D:FB:31:24:26:43:38:A3:6F:8A:88:7E:C1
```
