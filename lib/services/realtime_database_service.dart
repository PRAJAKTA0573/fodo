import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

/// Firebase Realtime Database Service
/// Handles all database operations
class RealtimeDatabaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final Logger _logger = Logger();

  /// Create or update user data
  Future<void> setUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _database.child('users/$userId').set(userData);
    } catch (e) {
      _logger.e('Error setting user data: $e');
      rethrow;
    }
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final snapshot = await _database.child('users/$userId').get();
      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user data: $e');
      rethrow;
    }
  }

  /// Update user data
  Future<void> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = ServerValue.timestamp;
      await _database.child('users/$userId').update(updates);
    } catch (e) {
      _logger.e('Error updating user data: $e');
      rethrow;
    }
  }

  /// Delete user data
  Future<void> deleteUser(String userId) async {
    try {
      await _database.child('users/$userId').remove();
    } catch (e) {
      _logger.e('Error deleting user data: $e');
      rethrow;
    }
  }

  /// Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final snapshot = await _database.child('users/$userId').get();
      return snapshot.exists;
    } catch (e) {
      _logger.e('Error checking user existence: $e');
      return false;
    }
  }

  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final snapshot = await _database
          .child('users')
          .orderByChild('email')
          .equalTo(email)
          .limitToFirst(1)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
        final userId = data.keys.first;
        return {
          'userId': userId,
          ...Map<String, dynamic>.from(data[userId] as Map<Object?, Object?>),
        };
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user by email: $e');
      rethrow;
    }
  }

  /// Create NGO data
  Future<void> setNGO(String ngoId, Map<String, dynamic> ngoData) async {
    try {
      await _database.child('ngos/$ngoId').set(ngoData);
    } catch (e) {
      _logger.e('Error setting NGO data: $e');
      rethrow;
    }
  }

  /// Get NGO data
  Future<Map<String, dynamic>?> getNGO(String ngoId) async {
    try {
      final snapshot = await _database.child('ngos/$ngoId').get();
      if (snapshot.exists && snapshot.value != null) {
        return Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting NGO data: $e');
      rethrow;
    }
  }

  /// Update NGO data
  Future<void> updateNGO(
    String ngoId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = ServerValue.timestamp;
      await _database.child('ngos/$ngoId').update(updates);
    } catch (e) {
      _logger.e('Error updating NGO data: $e');
      rethrow;
    }
  }

  /// Update NGO verification status
  Future<void> updateNGOVerificationStatus(
    String ngoId,
    String status,
    String? reason,
  ) async {
    try {
      await _database.child('ngos/$ngoId/verification').update({
        'status': status,
        'verifiedAt': status == 'verified' ? ServerValue.timestamp : null,
        'rejectionReason': reason,
      });
    } catch (e) {
      _logger.e('Error updating NGO verification: $e');
      rethrow;
    }
  }

  /// Listen to user data changes
  Stream<Map<String, dynamic>?> watchUser(String userId) {
    return _database.child('users/$userId').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map<Object?, Object?>);
      }
      return null;
    });
  }

  /// Listen to NGO data changes
  Stream<Map<String, dynamic>?> watchNGO(String ngoId) {
    return _database.child('ngos/$ngoId').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        return Map<String, dynamic>.from(event.snapshot.value as Map<Object?, Object?>);
      }
      return null;
    });
  }

  /// Upload file URL to database
  Future<void> uploadFileUrl(
    String path,
    String url,
  ) async {
    try {
      await _database.child(path).set(url);
    } catch (e) {
      _logger.e('Error uploading file URL: $e');
      rethrow;
    }
  }

  /// Get pending NGOs for verification
  Future<List<Map<String, dynamic>>> getPendingNGOs() async {
    try {
      final snapshot = await _database
          .child('ngos')
          .orderByChild('verification/status')
          .equalTo('pending')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<Object?, Object?>);
        return data.entries.map((entry) {
          return {
            'ngoId': entry.key,
            ...Map<String, dynamic>.from(entry.value as Map<Object?, Object?>),
          };
        }).toList();
      }
      return [];
    } catch (e) {
      _logger.e('Error getting pending NGOs: $e');
      rethrow;
    }
  }

  /// Perform transaction
  Future<void> runTransaction(
    String path,
    Map<String, dynamic> Function(Map<String, dynamic>?) update,
  ) async {
    try {
      final ref = _database.child(path);
      await ref.runTransaction((currentData) {
        if (currentData == null) {
          return Transaction.success(update(null));
        }
        final data = Map<String, dynamic>.from(currentData as Map<Object?, Object?>);
        return Transaction.success(update(data));
      });
    } catch (e) {
      _logger.e('Error running transaction: $e');
      rethrow;
    }
  }
}
