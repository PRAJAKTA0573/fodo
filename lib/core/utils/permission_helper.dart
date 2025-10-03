import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

/// Permission Helper
/// 
/// Handles runtime permission requests for camera, storage, location, etc.
class PermissionHelper {
  PermissionHelper._();

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library/storage permission
  static Future<bool> requestStoragePermission() async {
    // For Android 13+ (API 33+), use photos permission
    // For older versions, use storage permission
    if (await _isAndroid13OrHigher()) {
      final status = await Permission.photos.request();
      return status.isGranted;
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Request camera and storage permissions together (for image picker)
  static Future<bool> requestCameraAndStoragePermissions() async {
    final cameraStatus = await Permission.camera.request();
    
    PermissionStatus storageStatus;
    if (await _isAndroid13OrHigher()) {
      storageStatus = await Permission.photos.request();
    } else {
      storageStatus = await Permission.storage.request();
    }

    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if storage permission is granted
  static Future<bool> isStoragePermissionGranted() async {
    if (await _isAndroid13OrHigher()) {
      return await Permission.photos.isGranted;
    } else {
      return await Permission.storage.isGranted;
    }
  }

  /// Check if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  /// Open app settings
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Show permission denied dialog
  static void showPermissionDeniedDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Request camera permission with user-friendly dialog
  static Future<bool> requestCameraWithDialog(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        showPermissionDeniedDialog(
          context,
          title: 'Camera Permission Required',
          message:
              'FODO needs camera access to take photos of food donations. Please enable it in app settings.',
        );
      }
      return false;
    }

    return false;
  }

  /// Request storage permission with user-friendly dialog
  static Future<bool> requestStorageWithDialog(BuildContext context) async {
    Permission permission;
    if (await _isAndroid13OrHigher()) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        showPermissionDeniedDialog(
          context,
          title: 'Storage Permission Required',
          message:
              'FODO needs storage access to select photos from your gallery. Please enable it in app settings.',
        );
      }
      return false;
    }

    return false;
  }

  /// Request location permission with user-friendly dialog
  static Future<bool> requestLocationWithDialog(BuildContext context) async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        showPermissionDeniedDialog(
          context,
          title: 'Location Permission Required',
          message:
              'FODO needs location access to find nearby NGOs and help with donation pickups. Please enable it in app settings.',
        );
      }
      return false;
    }

    return false;
  }

  /// Request camera and storage with dialog (for image picker)
  static Future<bool> requestImagePermissionsWithDialog(
    BuildContext context, {
    required bool isCamera,
  }) async {
    if (isCamera) {
      // Request both camera and storage for taking photos
      final cameraGranted = await requestCameraWithDialog(context);
      if (!cameraGranted) return false;

      final storageGranted = await requestStorageWithDialog(context);
      return storageGranted;
    } else {
      // Request only storage for selecting from gallery
      return await requestStorageWithDialog(context);
    }
  }

  /// Check if running on Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    // This is a simplified check. In production, you might want to use
    // device_info_plus package to get actual Android version
    try {
      return await Permission.photos.status != PermissionStatus.denied;
    } catch (e) {
      return false;
    }
  }

  /// Show permission rationale dialog
  static Future<bool> showPermissionRationaleDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Request all necessary permissions for donation creation
  static Future<Map<String, bool>> requestDonationPermissions(
    BuildContext context,
  ) async {
    final results = <String, bool>{};

    // Request camera and storage
    results['camera'] = await requestCameraWithDialog(context);
    results['storage'] = await requestStorageWithDialog(context);
    results['location'] = await requestLocationWithDialog(context);

    return results;
  }

  /// Check all permissions status
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'camera': await Permission.camera.isGranted,
      'storage': await _isAndroid13OrHigher()
          ? await Permission.photos.isGranted
          : await Permission.storage.isGranted,
      'location': await Permission.location.isGranted,
    };
  }
}
