import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Location Service - Handles location detection and geocoding
class LocationService {
  /// Check if location permission is granted
  Future<bool> checkLocationPermission() async {
    final status = await ph.Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  Future<Either<String, bool>> requestLocationPermission() async {
    try {
      final status = await ph.Permission.location.request();
      
      if (status.isGranted) {
        return const Right(true);
      } else if (status.isDenied) {
        return const Left('Location permission denied');
      } else if (status.isPermanentlyDenied) {
        return const Left('Location permission permanently denied. Please enable it in settings.');
      } else {
        return const Left('Location permission not granted');
      }
    } catch (e) {
      return Left('Permission error: ${e.toString()}');
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location
  Future<Either<String, Position>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left('Location services are disabled. Please enable them.');
      }

      // Check permission
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        final permissionResult = await requestLocationPermission();
        if (permissionResult.isLeft()) {
          return Left(permissionResult.fold((l) => l, (r) => ''));
        }
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return Right(position);
    } catch (e) {
      return Left('Failed to get location: ${e.toString()}');
    }
  }

  /// Get address from coordinates (Reverse Geocoding)
  Future<Either<String, Map<String, String>>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return const Left('No address found for these coordinates');
      }

      final placemark = placemarks.first;

      final address = {
        'fullAddress': _buildFullAddress(placemark),
        'street': placemark.street ?? '',
        'locality': placemark.locality ?? '',
        'city': placemark.locality ?? placemark.subAdministrativeArea ?? '',
        'state': placemark.administrativeArea ?? '',
        'country': placemark.country ?? '',
        'pincode': placemark.postalCode ?? '',
        'subLocality': placemark.subLocality ?? '',
      };

      return Right(address);
    } catch (e) {
      return Left('Geocoding error: ${e.toString()}');
    }
  }

  /// Get coordinates from address (Forward Geocoding)
  Future<Either<String, Map<String, double>>> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        return const Left('No coordinates found for this address');
      }

      final location = locations.first;

      final coordinates = {
        'latitude': location.latitude,
        'longitude': location.longitude,
      };

      return Right(coordinates);
    } catch (e) {
      return Left('Geocoding error: ${e.toString()}');
    }
  }

  /// Calculate distance between two coordinates (in meters)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Calculate distance in kilometers
  double calculateDistanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final distanceInMeters = calculateDistance(lat1, lon1, lat2, lon2);
    return distanceInMeters / 1000;
  }

  /// Check if a location is within radius
  bool isWithinRadius(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radiusInKm,
  ) {
    final distance = calculateDistanceInKm(lat1, lon1, lat2, lon2);
    return distance <= radiusInKm;
  }

  /// Get last known location (faster but may be outdated)
  Future<Either<String, Position>> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      
      if (position == null) {
        // If no last known position, get current position
        return await getCurrentLocation();
      }

      return Right(position);
    } catch (e) {
      return Left('Failed to get last location: ${e.toString()}');
    }
  }

  /// Listen to location changes (real-time tracking)
  Stream<Position> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  /// Helper method to build full address string
  String _buildFullAddress(Placemark placemark) {
    final parts = <String>[];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      parts.add(placemark.postalCode!);
    }

    return parts.join(', ');
  }

  /// Validate coordinates
  bool validateCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Get location accuracy description
  String getAccuracyDescription(Position position) {
    final accuracy = position.accuracy;
    if (accuracy < 10) {
      return 'Excellent';
    } else if (accuracy < 50) {
      return 'Good';
    } else if (accuracy < 100) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }
}
