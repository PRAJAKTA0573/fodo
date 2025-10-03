# Google Maps API Key Setup Guide

## Current Issue
Your app is crashing with the error:
```
java.lang.IllegalStateException: API key not found. Check that <meta-data android:name="com.google.android.geo.API_KEY" android:value="your API key"/> is in the <application> element of AndroidManifest.xml
```

## Solution: Get and Configure Google Maps API Key

### Step 1: Get Your Google Maps API Key

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/

2. **Create/Select a Project**
   - If you don't have a project, click "Create Project"
   - Name it something like "FODO App"
   - Click "Create"

3. **Enable Google Maps APIs**
   - In the left sidebar, go to "APIs & Services" > "Library"
   - Search for and enable these APIs:
     - **Maps SDK for Android** ✅
     - **Maps SDK for iOS** ✅
     - **Geocoding API** ✅
     - **Places API** (optional, but recommended)

4. **Create API Key**
   - Go to "APIs & Services" > "Credentials"
   - Click "+ CREATE CREDENTIALS" > "API Key"
   - Copy your API key (it will look like: `AIzaSyXxxxxxxxxxxxxxxxxxxxxxxxxxx`)

5. **Restrict Your API Key (Recommended for Security)**
   
   **For Android:**
   - Click on your API key to edit it
   - Under "Application restrictions", select "Android apps"
   - Click "Add an item"
   - Package name: `com.yourcompany.fodo` (check your package name in `android/app/build.gradle`)
   - SHA-1 certificate fingerprint: Get it by running:
     ```bash
     # For debug key
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   
   **For iOS:**
   - Create a separate API key for iOS
   - Under "Application restrictions", select "iOS apps"
   - Add your bundle identifier: `com.yourcompany.fodo` (check in `ios/Runner/Info.plist`)

### Step 2: Add API Key to Your App

I've already updated the files with placeholders. Now you need to replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key:

#### For Android:
1. Open: `android/app/src/main/AndroidManifest.xml`
2. Find line 64:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
   ```
3. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

#### For iOS:
1. Open: `ios/Runner/AppDelegate.swift`
2. Find line 12:
   ```swift
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
   ```
3. Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key

### Step 3: Security Best Practice (Recommended)

Instead of hardcoding API keys, use environment variables:

1. **Create a secrets file:**
   ```bash
   touch android/local.properties
   ```

2. **Add your API key to `android/local.properties`:**
   ```properties
   MAPS_API_KEY=AIzaSyXxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

3. **Update `android/app/build.gradle`:**
   ```gradle
   android {
       ...
       defaultConfig {
           ...
           // Load API key from local.properties
           def localProperties = new Properties()
           def localPropertiesFile = rootProject.file('local.properties')
           if (localPropertiesFile.exists()) {
               localPropertiesFile.withReader('UTF-8') { reader ->
                   localProperties.load(reader)
               }
           }
           
           manifestPlaceholders = [
               MAPS_API_KEY: localProperties.getProperty('MAPS_API_KEY', '')
           ]
       }
   }
   ```

4. **Update AndroidManifest.xml:**
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="${MAPS_API_KEY}" />
   ```

5. **Add to .gitignore:**
   ```
   # Add this line to your .gitignore
   android/local.properties
   ```

### Step 4: Test Your Setup

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Verify maps work:**
   - The app should now load without crashing
   - Google Maps should display correctly
   - Location features should work

### Common Issues & Solutions

#### Issue: "API key not found"
- Make sure you replaced `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual key
- Check there are no extra spaces or quotes around the API key

#### Issue: "This API key is not authorized to use this service"
- Make sure you enabled "Maps SDK for Android" and "Maps SDK for iOS" in Google Cloud Console
- Check if your API key restrictions match your app's package name and SHA-1 fingerprint

#### Issue: Maps show "For development purposes only" watermark
- This means billing is not enabled on your Google Cloud project
- Go to Google Cloud Console > Billing
- You get $200 free credit per month, which is plenty for development

#### Issue: iOS app crashes
- Make sure you added `import GoogleMaps` in AppDelegate.swift
- Run `pod install` in the ios directory:
  ```bash
  cd ios
  pod install
  cd ..
  ```

### Quick Command Reference

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# For iOS - install CocoaPods dependencies
cd ios && pod install && cd ..

# Run app
flutter run

# Get SHA-1 for Android (debug)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Get SHA-1 for Android (release)
keytool -list -v -keystore /path/to/your/keystore -alias your_alias_name
```

### Testing Checklist

- [ ] Got API key from Google Cloud Console
- [ ] Enabled Maps SDK for Android
- [ ] Enabled Maps SDK for iOS
- [ ] Enabled Geocoding API
- [ ] Added API key to AndroidManifest.xml
- [ ] Added API key to AppDelegate.swift
- [ ] Ran `flutter clean` and `flutter pub get`
- [ ] App launches without crashing
- [ ] Maps display correctly
- [ ] Location permission works
- [ ] Current location shows on map

---

## Current Status

✅ **Android Configuration:** Added meta-data tag in `android/app/src/main/AndroidManifest.xml` (line 61-64)
✅ **iOS Configuration:** Added GMSServices configuration in `ios/Runner/AppDelegate.swift` (line 11-12)

❌ **Action Required:** Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual Google Maps API key

---

## Need Help?

If you encounter any issues:
1. Check the [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
2. Verify your API key works by testing it at: https://console.cloud.google.com/apis/credentials
3. Check the Flutter Google Maps plugin docs: https://pub.dev/packages/google_maps_flutter

## Free Tier Limits

Google Maps Platform free tier includes:
- $200 free credit per month
- Up to 28,000 map loads per month (free)
- Up to 40,000 geocoding requests per month (free)

This is more than enough for development and testing!
