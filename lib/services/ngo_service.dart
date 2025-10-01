import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:math' as math;

/// NGO Service - Handles all NGO-related database operations
class NGOService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Get NGO data by ID
  Future<Map<String, dynamic>?> getNGO(String ngoId) async {
    try {
      final snapshot = await _database.ref('ngos/$ngoId').get();
      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch NGO data: $e');
    }
  }

  /// Update NGO data
  Future<void> updateNGO(String ngoId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = ServerValue.timestamp;
      await _database.ref('ngos/$ngoId').update(data);
    } catch (e) {
      throw Exception('Failed to update NGO: $e');
    }
  }

  /// Get available donations (pending status)
  Future<List<Map<String, dynamic>>> getAvailableDonations() async {
    try {
      final snapshot = await _database
          .ref('donations')
          .orderByChild('status')
          .equalTo('pending')
          .get();

      if (!snapshot.exists) return [];

      final donations = <Map<String, dynamic>>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);

      data.forEach((key, value) {
        final donation = Map<String, dynamic>.from(value as Map<Object?, Object?>);
        donation['donationId'] = key;
        donations.add(donation);
      });

      return donations;
    } catch (e) {
      throw Exception('Failed to fetch available donations: $e');
    }
  }

  /// Get available donations as stream
  Stream<List<Map<String, dynamic>>> getAvailableDonationsStream() {
    return _database
        .ref('donations')
        .orderByChild('status')
        .equalTo('pending')
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <Map<String, dynamic>>[];

      final donations = <Map<String, dynamic>>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map<Object?, Object?>);

      data.forEach((key, value) {
        final donation = Map<String, dynamic>.from(value as Map<Object?, Object?>);
        donation['donationId'] = key;
        donations.add(donation);
      });

      return donations;
    });
  }

  /// Get NGO's accepted donations
  Future<List<Map<String, dynamic>>> getNGOAcceptedDonations(String ngoId) async {
    try {
      final snapshot = await _database
          .ref('donations')
          .orderByChild('acceptedBy/ngoId')
          .equalTo(ngoId)
          .get();

      if (!snapshot.exists) return [];

      final donations = <Map<String, dynamic>>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);

      data.forEach((key, value) {
        final donation = Map<String, dynamic>.from(value as Map<Object?, Object?>);
        donation['donationId'] = key;
        // Only include if not completed or cancelled
        if (donation['status'] != 'completed' && 
            donation['status'] != 'cancelled' &&
            donation['status'] != 'cancelled_by_donor') {
          donations.add(donation);
        }
      });

      return donations;
    } catch (e) {
      throw Exception('Failed to fetch NGO donations: $e');
    }
  }

  /// Get NGO's accepted donations as stream
  Stream<List<Map<String, dynamic>>> getNGOAcceptedDonationsStream(String ngoId) {
    return _database
        .ref('donations')
        .orderByChild('acceptedBy/ngoId')
        .equalTo(ngoId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <Map<String, dynamic>>[];

      final donations = <Map<String, dynamic>>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map<Object?, Object?>);

      data.forEach((key, value) {
        final donation = Map<String, dynamic>.from(value as Map<Object?, Object?>);
        donation['donationId'] = key;
        if (donation['status'] != 'completed' && 
            donation['status'] != 'cancelled' &&
            donation['status'] != 'cancelled_by_donor') {
          donations.add(donation);
        }
      });

      return donations;
    });
  }

  /// Get NGO's collection history (completed and cancelled)
  Future<List<Map<String, dynamic>>> getNGOCollectionHistory(String ngoId) async {
    try {
      final snapshot = await _database
          .ref('donations')
          .orderByChild('acceptedBy/ngoId')
          .equalTo(ngoId)
          .get();

      if (!snapshot.exists) return [];

      final donations = <Map<String, dynamic>>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);

      data.forEach((key, value) {
        final donation = Map<String, dynamic>.from(value as Map<Object?, Object?>);
        donation['donationId'] = key;
        // Only include completed or cancelled
        if (donation['status'] == 'completed' || 
            donation['status'] == 'cancelled') {
          donations.add(donation);
        }
      });

      // Sort by most recent first
      donations.sort((a, b) {
        final aTime = a['acceptedBy']?['acceptedAt'] ?? 0;
        final bTime = b['acceptedBy']?['acceptedAt'] ?? 0;
        return (bTime as int).compareTo(aTime as int);
      });

      return donations;
    } catch (e) {
      throw Exception('Failed to fetch collection history: $e');
    }
  }

  /// Accept a donation
  Future<void> acceptDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
    required String estimatedPickupTime,
  }) async {
    try {
      final updates = <String, dynamic>{
        'donations/$donationId/status': 'accepted',
        'donations/$donationId/acceptedBy': {
          'ngoId': ngoId,
          'ngoName': ngoName,
          'acceptedAt': ServerValue.timestamp,
          'estimatedPickupTime': estimatedPickupTime,
        },
        'donations/$donationId/updatedAt': ServerValue.timestamp,
      };

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to accept donation: $e');
    }
  }

  /// Update donation status
  Future<void> updateDonationStatus({
    required String donationId,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updates = <String, dynamic>{
        'donations/$donationId/status': status,
        'donations/$donationId/updatedAt': ServerValue.timestamp,
      };

      // Add status timestamp
      updates['donations/$donationId/statusHistory/$status'] = ServerValue.timestamp;

      // Add any additional data
      if (additionalData != null) {
        additionalData.forEach((key, value) {
          updates['donations/$donationId/$key'] = value;
        });
      }

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  /// Mark donation as collected
  Future<void> markAsCollected({
    required String donationId,
    String? notes,
  }) async {
    try {
      final additionalData = <String, dynamic>{
        'collection': {
          'collectedAt': ServerValue.timestamp,
          'notes': notes,
        }
      };

      await updateDonationStatus(
        donationId: donationId,
        status: 'collected',
        additionalData: additionalData,
      );
    } catch (e) {
      throw Exception('Failed to mark as collected: $e');
    }
  }

  /// Mark donation as distributed
  Future<void> markAsDistributed({
    required String donationId,
    required int beneficiariesCount,
    List<String>? distributionPhotos,
    String? notes,
  }) async {
    try {
      final additionalData = <String, dynamic>{
        'distribution': {
          'distributedAt': ServerValue.timestamp,
          'beneficiariesCount': beneficiariesCount,
          'distributionPhotos': distributionPhotos ?? [],
          'notes': notes,
        }
      };

      await updateDonationStatus(
        donationId: donationId,
        status: 'distributed',
        additionalData: additionalData,
      );
    } catch (e) {
      throw Exception('Failed to mark as distributed: $e');
    }
  }

  /// Complete donation
  Future<void> completeDonation({
    required String donationId,
    required String ngoId,
    required int beneficiariesCount,
  }) async {
    try {
      // Update donation status
      await updateDonationStatus(
        donationId: donationId,
        status: 'completed',
        additionalData: {
          'completedAt': ServerValue.timestamp,
        },
      );

      // Update NGO statistics
      await _updateNGOStatistics(ngoId, beneficiariesCount);
    } catch (e) {
      throw Exception('Failed to complete donation: $e');
    }
  }

  /// Update NGO statistics
  Future<void> _updateNGOStatistics(String ngoId, int peopleFed) async {
    try {
      final ngoRef = _database.ref('ngos/$ngoId/statistics');
      final snapshot = await ngoRef.get();

      if (snapshot.exists && snapshot.value != null) {
        final stats = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
        await ngoRef.update({
          'totalCollections': (stats['totalCollections'] ?? 0) + 1,
          'completedCollections': (stats['completedCollections'] ?? 0) + 1,
          'totalPeopleFed': (stats['totalPeopleFed'] ?? 0) + peopleFed,
        });
      }
    } catch (e) {
      // Don't throw, just log - statistics update is not critical
      // Note: Using a warning comment instead of print for production code
    }
  }

  /// Calculate distance between two coordinates (in kilometers)
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Get donations within radius
  List<Map<String, dynamic>> filterDonationsByDistance({
    required List<Map<String, dynamic>> donations,
    required double ngoLat,
    required double ngoLon,
    required double maxDistanceKm,
  }) {
    return donations.where((donation) {
      final donationLat = (donation['location']?['coordinates']?['latitude'] ?? 0.0) as num;
      final donationLon = (donation['location']?['coordinates']?['longitude'] ?? 0.0) as num;

      final distance = calculateDistance(
        lat1: ngoLat,
        lon1: ngoLon,
        lat2: donationLat.toDouble(),
        lon2: donationLon.toDouble(),
      );

      return distance <= maxDistanceKm;
    }).toList();
  }

  /// Sort donations by distance
  List<Map<String, dynamic>> sortDonationsByDistance({
    required List<Map<String, dynamic>> donations,
    required double ngoLat,
    required double ngoLon,
  }) {
    final donationsWithDistance = donations.map((donation) {
      final donationLat = (donation['location']?['coordinates']?['latitude'] ?? 0.0) as num;
      final donationLon = (donation['location']?['coordinates']?['longitude'] ?? 0.0) as num;

      final distance = calculateDistance(
        lat1: ngoLat,
        lon1: ngoLon,
        lat2: donationLat.toDouble(),
        lon2: donationLon.toDouble(),
      );

      return {
        ...donation,
        'distance': distance,
      };
    }).toList();

    donationsWithDistance.sort((a, b) => 
      (a['distance'] as double).compareTo(b['distance'] as double)
    );

    return donationsWithDistance;
  }

  /// Get donation by ID
  Future<Map<String, dynamic>?> getDonation(String donationId) async {
    try {
      final snapshot = await _database.ref('donations/$donationId').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
        data['donationId'] = donationId;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch donation: $e');
    }
  }

  /// Get donation as stream
  Stream<Map<String, dynamic>?> getDonationStream(String donationId) {
    return _database.ref('donations/$donationId').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return null;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map<Object?, Object?>);
      data['donationId'] = donationId;
      return data;
    });
  }
}
