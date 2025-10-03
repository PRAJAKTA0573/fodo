# Location Permission Crash Fix

## Problem
The app was crashing when requesting location permission after the user clicked "Allow".

## Root Cause
There were **3 critical bugs** causing the crash:

### 1. Recursive Function Call in `permission_helper.dart` (line 70)
```dart
// ❌ WRONG - Infinite recursion
static Future<void> openAppSettings() async {
  await openAppSettings(); // Calls itself infinitely!
}
```

The `openAppSettings()` method was calling itself recursively instead of calling the actual permission handler function, causing a stack overflow and app crash.

### 2. Similar Issue in `location_service.dart` (line 192)
```dart
// ❌ WRONG - Infinite recursion
Future<void> openAppSettings() async {
  await openAppSettings(); // Calls itself infinitely!
}
```

Same recursive call issue in the location service.

### 3. Missing Context Checks
The location permission request didn't check if the widget was still mounted before updating state, which could cause crashes if the widget was disposed during async operations.

## Solution Applied

### Fix 1: Rename method in `permission_helper.dart` to avoid conflict
```dart
// ✅ CORRECT - Renamed to avoid conflict
static Future<void> openSettings() async {
  await openAppSettings(); // Calls the actual permission_handler function
}
```

### Fix 2: Use namespaced import in `location_service.dart`
```dart
// Import with alias to avoid naming conflicts
import 'package:permission_handler/permission_handler.dart' as ph;

// ✅ CORRECT - Uses the imported function with namespace
Future<void> openAppSettings() async {
  await ph.openAppSettings(); // Explicitly calls permission_handler's function
}

// Also updated permission checks
Future<bool> checkLocationPermission() async {
  final status = await ph.Permission.location.status;
  return status.isGranted;
}

Future<Either<String, bool>> requestLocationPermission() async {
  try {
    final status = await ph.Permission.location.request();
    // ... rest of the logic
  } catch (e) {
    return Left('Permission error: ${e.toString()}');
  }
}
```

### Fix 3: Add proper error handling in `location_picker_page.dart`
```dart
Future<void> _getCurrentLocation() async {
  try {
    setState(() => _isLoadingLocation = true);

    final result = await _locationService.getCurrentLocation();

    // ✅ Check if widget is still mounted before updating UI
    if (!mounted) return;

    result.fold(
      (error) {
        // Handle error...
      },
      (position) {
        // Handle success...
      },
    );
  } catch (e) {
    // ✅ Catch any unexpected errors
    if (!mounted) return;
    setState(() {
      _selectedLocation = _defaultLocation;
      _isLoadingLocation = false;
    });
    // Show error message...
  }
}
```

## Files Modified
1. `lib/core/utils/permission_helper.dart` - Fixed recursive call by renaming method
2. `lib/services/location_service.dart` - Used namespace import to call correct function
3. `lib/features/donor/presentation/pages/location_picker_page.dart` - Added error handling and mounted checks

## Testing Steps
1. Clean the project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Run the app on a physical device or emulator
4. Navigate to a screen that requests location permission
5. Click "Allow" when the permission dialog appears
6. The app should now work correctly without crashing

## Additional Notes
- The issue was caused by method name conflicts with the `permission_handler` package's top-level `openAppSettings()` function
- Using a namespace alias (`as ph`) is a good practice to avoid such conflicts
- Always check `mounted` before calling `setState()` after async operations to avoid crashes when widgets are disposed

## Prevention
To avoid similar issues in the future:
- Avoid naming methods the same as package functions
- Use namespace imports for packages with common function names
- Always add try-catch blocks for async operations
- Check widget lifecycle (mounted) before updating state after async calls
