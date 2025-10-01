# 🔐 FODO Permissions Guide

## Overview

FODO requires several permissions to provide full functionality for food donation management. This guide explains all permissions, their purposes, and how to handle them.

---

## 📱 Required Permissions

### 1. **Camera** 📷
**Purpose**: Take photos of food donations

**Android**: `CAMERA`
**iOS**: `NSCameraUsageDescription`

**When Requested**: When user taps "Take Photo" while creating a donation

**User Message**: 
- Android: System default or "FODO needs camera access to take photos of food donations"
- iOS: "FODO needs access to your camera to take photos of food donations."

---

### 2. **Photo Library / Storage** 🖼️
**Purpose**: Select existing photos from gallery

**Android**: 
- `READ_MEDIA_IMAGES` (Android 13+)
- `READ_EXTERNAL_STORAGE` (Android < 13)

**iOS**: 
- `NSPhotoLibraryUsageDescription`
- `NSPhotoLibraryAddUsageDescription`

**When Requested**: When user taps "Choose from Gallery" while creating a donation

**User Message**: 
- Android: System photo picker or "Allow FODO to access photos?"
- iOS: "FODO needs access to your photo library to select photos of food donations."

---

### 3. **Location** 📍
**Purpose**: 
- Show donor's location on map
- Find nearby NGOs
- Calculate distance for pickup
- Enable location-based features

**Android**: 
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION` (optional)

**iOS**: 
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

**When Requested**: 
- When creating a donation and selecting location
- When viewing nearby donations (NGO)
- When accessing map features

**User Message**: 
- Android: "Allow FODO to access this device's location?"
- iOS: "FODO needs your location to show nearby NGOs and help with food donation pickups."

---

### 4. **Internet** 🌐
**Purpose**: 
- Connect to Firebase
- Upload images to storage
- Real-time data sync
- Push notifications

**Android**: 
- `INTERNET`
- `ACCESS_NETWORK_STATE`

**iOS**: Automatically granted

**When Requested**: Never (automatically granted)

---

## 🔧 Implementation Details

### Android Configuration

**File**: `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Camera Permission -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Storage Permissions (Android < 13) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />

<!-- Storage Permissions (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />

<!-- Location Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Internet Permission -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS Configuration

**File**: `ios/Runner/Info.plist`

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>FODO needs access to your camera to take photos of food donations.</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>FODO needs access to your photo library to select photos of food donations.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>FODO needs access to save photos to your photo library.</string>

<!-- Location Permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>FODO needs your location to show nearby NGOs and help with food donation pickups.</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>FODO needs your location to provide donation tracking and nearby NGO alerts.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>FODO needs your location to show nearby donations and optimize food distribution.</string>
```

---

## 🛠️ Using PermissionHelper

### Basic Usage

```dart
import 'package:fodo/core/utils/permission_helper.dart';

// Request camera permission
final granted = await PermissionHelper.requestCameraPermission();

// Request storage permission
final storageGranted = await PermissionHelper.requestStoragePermission();

// Request location permission
final locationGranted = await PermissionHelper.requestLocationPermission();
```

### With User-Friendly Dialogs

```dart
// Request camera with dialog
final granted = await PermissionHelper.requestCameraWithDialog(context);

// Request storage with dialog
final storageGranted = await PermissionHelper.requestStorageWithDialog(context);

// Request location with dialog
final locationGranted = await PermissionHelper.requestLocationWithDialog(context);
```

### For Image Picker

```dart
// Request permissions for camera
final cameraGranted = await PermissionHelper.requestImagePermissionsWithDialog(
  context,
  isCamera: true,
);

// Request permissions for gallery
final galleryGranted = await PermissionHelper.requestImagePermissionsWithDialog(
  context,
  isCamera: false,
);
```

### Check Permission Status

```dart
// Check if camera is granted
final isCameraGranted = await PermissionHelper.isCameraPermissionGranted();

// Check if storage is granted
final isStorageGranted = await PermissionHelper.isStoragePermissionGranted();

// Check if location is granted
final isLocationGranted = await PermissionHelper.isLocationPermissionGranted();

// Check all permissions
final allPermissions = await PermissionHelper.checkAllPermissions();
// Returns: {'camera': true, 'storage': true, 'location': false}
```

### Request All Donation Permissions

```dart
// Request all permissions needed for creating a donation
final results = await PermissionHelper.requestDonationPermissions(context);

if (results['camera'] == true && results['storage'] == true) {
  // Proceed with image picker
  _pickImage();
} else {
  // Show error or guide user to settings
  _showPermissionError();
}
```

---

## 🎯 Permission Flow

### Creating a Donation

```
User taps "Create Donation"
        ↓
User taps "Add Photos"
        ↓
Show Camera/Gallery options
        ↓
User selects Camera
        ↓
Check Camera Permission
        ↓
  ┌─ Granted → Open Camera
  │
  ├─ Denied → Request Permission
  │            ↓
  │          User Allows → Open Camera
  │          User Denies → Show error
  │
  └─ Permanently Denied → Show dialog with "Open Settings"
```

### Selecting Location

```
User taps "Select Location"
        ↓
Check Location Permission
        ↓
  ┌─ Granted → Show Map
  │
  ├─ Denied → Request Permission
  │            ↓
  │          User Allows → Show Map
  │          User Denies → Show manual input
  │
  └─ Permanently Denied → Show dialog with "Open Settings"
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: Camera Not Working

**Symptoms**: Camera doesn't open when tapped

**Solutions**:
1. Check if camera permission is granted:
   ```dart
   final granted = await Permission.camera.isGranted;
   print('Camera granted: $granted');
   ```

2. Request permission explicitly:
   ```dart
   await PermissionHelper.requestCameraWithDialog(context);
   ```

3. Check device settings:
   - Android: Settings → Apps → FODO → Permissions → Camera
   - iOS: Settings → FODO → Camera

4. Rebuild the app after adding permissions:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

### Issue 2: Gallery Not Opening

**Symptoms**: Nothing happens when selecting from gallery

**Solutions**:
1. Check Android version:
   - Android 13+: Needs `READ_MEDIA_IMAGES`
   - Android < 13: Needs `READ_EXTERNAL_STORAGE`

2. Request appropriate permission:
   ```dart
   await PermissionHelper.requestStorageWithDialog(context);
   ```

3. For Android 13+, use the system photo picker (automatic)

4. Check device settings:
   - Android: Settings → Apps → FODO → Permissions → Photos
   - iOS: Settings → FODO → Photos

---

### Issue 3: Location Not Detected

**Symptoms**: Location features not working, map not loading

**Solutions**:
1. Check if location services are enabled on device:
   - Android: Settings → Location → On
   - iOS: Settings → Privacy → Location Services → On

2. Check app permission:
   ```dart
   final granted = await Permission.location.isGranted;
   print('Location granted: $granted');
   ```

3. Request location permission:
   ```dart
   await PermissionHelper.requestLocationWithDialog(context);
   ```

4. Check if location service is running (Android):
   - Ensure Geolocator is properly initialized
   - Check for location accuracy settings

---

### Issue 4: Permission Permanently Denied

**Symptoms**: Permission dialog doesn't show up, app can't request permission

**Solutions**:
1. Guide user to app settings:
   ```dart
   PermissionHelper.showPermissionDeniedDialog(
     context,
     title: 'Permission Required',
     message: 'Please enable this permission in app settings.',
   );
   ```

2. User must manually enable permission:
   - Android: Settings → Apps → FODO → Permissions
   - iOS: Settings → FODO → Enable required permission

3. After enabling, user should restart the app

---

### Issue 5: Android 13+ Storage Issues

**Symptoms**: Gallery works on older Android but not on Android 13+

**Solutions**:
1. Ensure `READ_MEDIA_IMAGES` is in manifest

2. Use photos permission instead of storage:
   ```dart
   final status = await Permission.photos.request();
   ```

3. The system photo picker is automatically used on Android 13+

4. If old permission is permanently denied, users must go to settings

---

## 🧪 Testing Permissions

### Testing Permission Flow

1. **Grant Permission Flow**:
   ```bash
   # Uninstall app
   adb uninstall com.example.fodo
   
   # Reinstall
   flutter run
   
   # Try features and grant permissions when prompted
   ```

2. **Deny Permission Flow**:
   - Deny permission when prompted
   - Verify app shows appropriate error message
   - Verify "Open Settings" button works

3. **Permanently Denied Flow**:
   - Deny permission twice
   - Verify permanently denied dialog shows
   - Verify settings button opens app settings
   - Grant permission in settings
   - Verify app detects granted permission

### ADB Commands for Testing (Android)

```bash
# Check granted permissions
adb shell dumpsys package com.example.fodo | grep permission

# Revoke camera permission
adb shell pm revoke com.example.fodo android.permission.CAMERA

# Grant camera permission
adb shell pm grant com.example.fodo android.permission.CAMERA

# Revoke storage permission (Android < 13)
adb shell pm revoke com.example.fodo android.permission.READ_EXTERNAL_STORAGE

# Grant storage permission
adb shell pm grant com.example.fodo android.permission.READ_EXTERNAL_STORAGE

# Revoke location permission
adb shell pm revoke com.example.fodo android.permission.ACCESS_FINE_LOCATION

# Grant location permission
adb shell pm grant com.example.fodo android.permission.ACCESS_FINE_LOCATION
```

---

## 📝 Best Practices

### 1. **Ask at the Right Time**
- Don't request all permissions at startup
- Request permission when user tries to use the feature
- Provide context before requesting sensitive permissions

### 2. **Provide Clear Messaging**
- Explain why the permission is needed
- Use clear, concise language
- Show benefits to the user

### 3. **Handle Denials Gracefully**
- Don't block the entire app if optional permission is denied
- Provide alternative workflows when possible
- Guide users to settings for permanently denied permissions

### 4. **Test on Multiple Android Versions**
- Android 13+ has different photo picker
- Older versions use different permissions
- Test on API levels 21-34

### 5. **Monitor Permission Status**
- Check permission status before using features
- Handle permission revocation at runtime
- Provide feedback when permissions change

---

## 🔄 Permission State Management

### Permission States

| State | Description | Action |
|-------|-------------|--------|
| **Granted** | User has granted permission | Proceed with feature |
| **Denied** | User has denied once | Request again with rationale |
| **Permanently Denied** | User denied twice+ | Guide to settings |
| **Restricted** | System-level restriction | Inform user, cannot request |

### Handling Each State

```dart
final status = await Permission.camera.status;

if (status.isGranted) {
  // Use camera
  _openCamera();
} else if (status.isDenied) {
  // Request permission
  final result = await Permission.camera.request();
  if (result.isGranted) {
    _openCamera();
  }
} else if (status.isPermanentlyDenied) {
  // Show settings dialog
  PermissionHelper.showPermissionDeniedDialog(
    context,
    title: 'Camera Permission',
    message: 'Please enable camera in settings',
  );
} else if (status.isRestricted) {
  // System restriction
  _showError('Camera is restricted by system policy');
}
```

---

## 📚 Resources

- **Flutter Permission Handler**: https://pub.dev/packages/permission_handler
- **Android Permissions Guide**: https://developer.android.com/guide/topics/permissions/overview
- **iOS Permissions Guide**: https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy
- **Android 13 Photo Picker**: https://developer.android.com/training/data-storage/shared/photopicker

---

## ✅ Checklist

Before submitting to stores:

- [ ] All required permissions added to AndroidManifest.xml
- [ ] All usage descriptions added to Info.plist (iOS)
- [ ] Permission requests happen at appropriate times
- [ ] Clear explanations provided to users
- [ ] Denied permissions handled gracefully
- [ ] Settings navigation works correctly
- [ ] Tested on multiple Android versions
- [ ] Tested on multiple iOS versions
- [ ] Privacy policy updated with permission usage
- [ ] Play Store listing mentions permissions

---

**Last Updated**: October 1, 2025  
**Version**: 1.0.0  
**Status**: Production Ready ✅

---

*Built with 🔐 for FODO - Secure permissions for seamless food donation!*
