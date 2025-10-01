import 'package:firebase_database/firebase_database.dart';
import 'package:dartz/dartz.dart';
import '../features/donor/data/models/donation_model.dart';

/// Donation Service - Handles all donation operations with Firebase Realtime Database
class DonationService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Get donations reference
  DatabaseReference get _donationsRef => _database.ref('donations');

  /// Create a new donation
  Future<Either<String, String>> createDonation(DonationModel donation) async {
    try {
      // Generate new donation ID
      final newDonationRef = _donationsRef.push();
      final donationId = newDonationRef.key!;

      // Create donation with generated ID
      final donationWithId = donation.copyWith(donationId: donationId);

      await newDonationRef.set(donationWithId.toDatabase());

      return Right(donationId);
    } catch (e) {
      return Left('Failed to create donation: ${e.toString()}');
    }
  }

  /// Get donation by ID
  Future<Either<String, DonationModel>> getDonation(String donationId) async {
    try {
      final snapshot = await _donationsRef.child(donationId).get();

      if (!snapshot.exists) {
        return const Left('Donation not found');
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final donation = DonationModel.fromDatabase(data, donationId);

      return Right(donation);
    } catch (e) {
      return Left('Failed to get donation: ${e.toString()}');
    }
  }

  /// Get all donations by donor ID
  Future<Either<String, List<DonationModel>>> getDonationsByDonor(
    String donorId,
  ) async {
    try {
      final query = _donationsRef
          .orderByChild('donorId')
          .equalTo(donorId);

      final snapshot = await query.get();

      if (!snapshot.exists) {
        return const Right([]);
      }

      final donations = <DonationModel>[];
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      data.forEach((key, value) {
        final donationData = Map<String, dynamic>.from(value as Map);
        donations.add(DonationModel.fromDatabase(donationData, key));
      });

      // Sort by creation date (newest first)
      donations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Right(donations);
    } catch (e) {
      return Left('Failed to get donations: ${e.toString()}');
    }
  }

  /// Get donations by status
  Future<Either<String, List<DonationModel>>> getDonationsByStatus(
    String donorId,
    String status,
  ) async {
    try {
      final allDonations = await getDonationsByDonor(donorId);

      return allDonations.fold(
        (error) => Left(error),
        (donations) {
          final filtered = donations
              .where((d) => d.status.value == status)
              .toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left('Failed to filter donations: ${e.toString()}');
    }
  }

  /// Update donation
  Future<Either<String, void>> updateDonation(
    String donationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updated timestamp
      updates['updatedAt'] = ServerValue.timestamp;

      await _donationsRef.child(donationId).update(updates);

      return const Right(null);
    } catch (e) {
      return Left('Failed to update donation: ${e.toString()}');
    }
  }

  /// Update donation status
  Future<Either<String, void>> updateDonationStatus(
    String donationId,
    String newStatus,
    {DateTime? timestamp}
  ) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus,
        'updatedAt': ServerValue.timestamp,
      };

      // Update timeline based on status
      final timeField = _getTimelineFieldForStatus(newStatus);
      if (timeField != null) {
        updates['timeline/$timeField'] = 
            timestamp?.millisecondsSinceEpoch ?? ServerValue.timestamp;
      }

      await _donationsRef.child(donationId).update(updates);

      return const Right(null);
    } catch (e) {
      return Left('Failed to update status: ${e.toString()}');
    }
  }

  /// Cancel donation
  Future<Either<String, void>> cancelDonation(
    String donationId,
    String reason,
  ) async {
    try {
      final updates = <String, dynamic>{
        'status': 'cancelled',
        'cancellationReason': reason,
        'timeline/cancelledAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };

      await _donationsRef.child(donationId).update(updates);

      return const Right(null);
    } catch (e) {
      return Left('Failed to cancel donation: ${e.toString()}');
    }
  }

  /// Add rating to donation
  Future<Either<String, void>> addRating(
    String donationId,
    double rating,
    String? comment,
  ) async {
    try {
      final ratingData = {
        'rating': {
          'rating': rating,
          'comment': comment,
          'ratedAt': ServerValue.timestamp,
        },
        'updatedAt': ServerValue.timestamp,
      };

      await _donationsRef.child(donationId).update(ratingData);

      return const Right(null);
    } catch (e) {
      return Left('Failed to add rating: ${e.toString()}');
    }
  }

  /// Delete donation (soft delete - mark as deleted)
  Future<Either<String, void>> deleteDonation(String donationId) async {
    try {
      // In a real app, you might want to keep deleted donations
      // For now, we'll actually delete it
      await _donationsRef.child(donationId).remove();

      return const Right(null);
    } catch (e) {
      return Left('Failed to delete donation: ${e.toString()}');
    }
  }

  /// Get active donations (not completed, cancelled, or expired)
  Future<Either<String, List<DonationModel>>> getActiveDonations(
    String donorId,
  ) async {
    try {
      final allDonations = await getDonationsByDonor(donorId);

      return allDonations.fold(
        (error) => Left(error),
        (donations) {
          final activeStatuses = ['created', 'visible', 'accepted', 'inTransit', 'collected'];
          final active = donations
              .where((d) => activeStatuses.contains(d.status.value))
              .toList();
          return Right(active);
        },
      );
    } catch (e) {
      return Left('Failed to get active donations: ${e.toString()}');
    }
  }

  /// Get donation count by donor
  Future<Either<String, int>> getDonationCount(String donorId) async {
    try {
      final donations = await getDonationsByDonor(donorId);

      return donations.fold(
        (error) => Left(error),
        (list) => Right(list.length),
      );
    } catch (e) {
      return Left('Failed to get count: ${e.toString()}');
    }
  }

  /// Listen to donation changes (real-time)
  Stream<DonationModel?> listenToDonation(String donationId) {
    return _donationsRef.child(donationId).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return DonationModel.fromDatabase(data, donationId);
    });
  }

  /// Listen to all donations by donor (real-time)
  Stream<List<DonationModel>> listenToDonationsByDonor(String donorId) {
    return _donationsRef
        .orderByChild('donorId')
        .equalTo(donorId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists) return <DonationModel>[];

      final donations = <DonationModel>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      data.forEach((key, value) {
        final donationData = Map<String, dynamic>.from(value as Map);
        donations.add(DonationModel.fromDatabase(donationData, key));
      });

      donations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return donations;
    });
  }

  /// Helper method to get timeline field name for status
  String? _getTimelineFieldForStatus(String status) {
    switch (status) {
      case 'visible':
        return 'visibleAt';
      case 'accepted':
        return 'acceptedAt';
      case 'inTransit':
        return 'inTransitAt';
      case 'collected':
        return 'collectedAt';
      case 'distributed':
        return 'distributedAt';
      case 'completed':
        return 'completedAt';
      case 'cancelled':
        return 'cancelledAt';
      default:
        return null;
    }
  }

  /// Get donation statistics for donor
  Future<Either<String, Map<String, int>>> getDonationStatistics(
    String donorId,
  ) async {
    try {
      final donations = await getDonationsByDonor(donorId);

      return donations.fold(
        (error) => Left(error),
        (list) {
          final stats = <String, int>{
            'total': list.length,
            'completed': list.where((d) => d.status.value == 'completed').length,
            'active': list.where((d) => 
              ['created', 'visible', 'accepted', 'inTransit', 'collected']
                .contains(d.status.value)
            ).length,
            'cancelled': list.where((d) => d.status.value == 'cancelled').length,
            'totalPeopleFed': list
              .where((d) => d.status.value == 'completed')
              .fold(0, (sum, d) => sum + d.foodDetails.estimatedPeopleFed),
          };
          return Right(stats);
        },
      );
    } catch (e) {
      return Left('Failed to get statistics: ${e.toString()}');
    }
  }
}
