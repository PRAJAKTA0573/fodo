import 'package:dartz/dartz.dart';
import '../../../../services/ngo_service.dart';
import '../../../../services/realtime_database_service.dart';
import '../models/ngo_model.dart';
import '../../../donor/data/models/donation_model.dart';

/// NGO Repository Implementation with business logic and error handling
class NGORepositoryImpl {
  final NGOService _ngoService;
  // ignore: unused_field
  final RealtimeDatabaseService _dbService;

  NGORepositoryImpl(this._ngoService, this._dbService);

  /// Get NGO details
  Future<Either<String, NGOModel>> getNGO(String ngoId) async {
    try {
      final data = await _ngoService.getNGO(ngoId);
      if (data == null) {
        return Left('NGO not found');
      }
      final ngo = NGOModel.fromDatabase(data, ngoId);
      return Right(ngo);
    } catch (e) {
      return Left('Failed to fetch NGO: ${e.toString()}');
    }
  }

  /// Update NGO details
  Future<Either<String, void>> updateNGO(NGOModel ngo) async {
    try {
      await _ngoService.updateNGO(ngo.ngoId, ngo.toDatabase());
      return const Right(null);
    } catch (e) {
      return Left('Failed to update NGO: ${e.toString()}');
    }
  }

  /// Get available donations
  Future<Either<String, List<DonationModel>>> getAvailableDonations() async {
    try {
      final data = await _ngoService.getAvailableDonations();
      final donations = data.map((d) => 
        DonationModel.fromDatabase(d, d['donationId'])
      ).toList();
      return Right(donations);
    } catch (e) {
      return Left('Failed to fetch donations: ${e.toString()}');
    }
  }

  /// Get available donations stream
  Stream<List<DonationModel>> getAvailableDonationsStream() {
    return _ngoService.getAvailableDonationsStream().map((data) {
      return data.map((d) => 
        DonationModel.fromDatabase(d, d['donationId'])
      ).toList();
    });
  }

  /// Get NGO's active pickups
  Future<Either<String, List<DonationModel>>> getActivePickups(String ngoId) async {
    try {
      final data = await _ngoService.getNGOAcceptedDonations(ngoId);
      final donations = data.map((d) => 
        DonationModel.fromDatabase(d, d['donationId'])
      ).toList();
      return Right(donations);
    } catch (e) {
      return Left('Failed to fetch pickups: ${e.toString()}');
    }
  }

  /// Get NGO's active pickups stream
  Stream<List<DonationModel>> getActivePickupsStream(String ngoId) {
    return _ngoService.getNGOAcceptedDonationsStream(ngoId).map((data) {
      return data.map((d) => 
        DonationModel.fromDatabase(d, d['donationId'])
      ).toList();
    });
  }

  /// Get NGO's collection history
  Future<Either<String, List<DonationModel>>> getCollectionHistory(String ngoId) async {
    try {
      final data = await _ngoService.getNGOCollectionHistory(ngoId);
      final donations = data.map((d) => 
        DonationModel.fromDatabase(d, d['donationId'])
      ).toList();
      return Right(donations);
    } catch (e) {
      return Left('Failed to fetch history: ${e.toString()}');
    }
  }

  /// Accept a donation
  Future<Either<String, void>> acceptDonation({
    required String donationId,
    required String ngoId,
    required String ngoName,
    required String estimatedPickupTime,
  }) async {
    try {
      // Check if donation is still available
      final donationData = await _ngoService.getDonation(donationId);
      if (donationData == null) {
        return Left('Donation not found');
      }

      if (donationData['status'] != 'pending') {
        return Left('This donation is no longer available');
      }

      await _ngoService.acceptDonation(
        donationId: donationId,
        ngoId: ngoId,
        ngoName: ngoName,
        estimatedPickupTime: estimatedPickupTime,
      );

      return const Right(null);
    } catch (e) {
      return Left('Failed to accept donation: ${e.toString()}');
    }
  }

  /// Update donation status to "on_the_way"
  Future<Either<String, void>> markOnTheWay(String donationId) async {
    try {
      await _ngoService.updateDonationStatus(
        donationId: donationId,
        status: 'on_the_way',
      );
      return const Right(null);
    } catch (e) {
      return Left('Failed to update status: ${e.toString()}');
    }
  }

  /// Update donation status to "reached"
  Future<Either<String, void>> markReached(String donationId) async {
    try {
      await _ngoService.updateDonationStatus(
        donationId: donationId,
        status: 'reached',
      );
      return const Right(null);
    } catch (e) {
      return Left('Failed to update status: ${e.toString()}');
    }
  }

  /// Mark donation as collected
  Future<Either<String, void>> markCollected({
    required String donationId,
    String? notes,
  }) async {
    try {
      await _ngoService.markAsCollected(
        donationId: donationId,
        notes: notes,
      );
      return const Right(null);
    } catch (e) {
      return Left('Failed to mark as collected: ${e.toString()}');
    }
  }

  /// Mark donation as distributed
  Future<Either<String, void>> markDistributed({
    required String donationId,
    required int beneficiariesCount,
    List<String>? distributionPhotos,
    String? notes,
  }) async {
    try {
      if (beneficiariesCount <= 0) {
        return Left('Beneficiaries count must be greater than 0');
      }

      await _ngoService.markAsDistributed(
        donationId: donationId,
        beneficiariesCount: beneficiariesCount,
        distributionPhotos: distributionPhotos,
        notes: notes,
      );
      return const Right(null);
    } catch (e) {
      return Left('Failed to mark as distributed: ${e.toString()}');
    }
  }

  /// Complete donation
  Future<Either<String, void>> completeDonation({
    required String donationId,
    required String ngoId,
    required int beneficiariesCount,
  }) async {
    try {
      if (beneficiariesCount <= 0) {
        return Left('Beneficiaries count must be greater than 0');
      }

      await _ngoService.completeDonation(
        donationId: donationId,
        ngoId: ngoId,
        beneficiariesCount: beneficiariesCount,
      );
      return const Right(null);
    } catch (e) {
      return Left('Failed to complete donation: ${e.toString()}');
    }
  }

  /// Filter donations by distance
  List<DonationModel> filterByDistance({
    required List<DonationModel> donations,
    required double ngoLat,
    required double ngoLon,
    required double maxDistanceKm,
  }) {
    final donationsData = donations.map((d) => d.toDatabase()).toList();
    final filtered = _ngoService.filterDonationsByDistance(
      donations: donationsData,
      ngoLat: ngoLat,
      ngoLon: ngoLon,
      maxDistanceKm: maxDistanceKm,
    );
    return filtered.map((d) => DonationModel.fromDatabase(d, d['donationId'])).toList();
  }

  /// Sort donations by distance
  List<DonationModel> sortByDistance({
    required List<DonationModel> donations,
    required double ngoLat,
    required double ngoLon,
  }) {
    final donationsData = donations.map((d) => d.toDatabase()).toList();
    final sorted = _ngoService.sortDonationsByDistance(
      donations: donationsData,
      ngoLat: ngoLat,
      ngoLon: ngoLon,
    );
    return sorted.map((d) => DonationModel.fromDatabase(d, d['donationId'])).toList();
  }

  /// Calculate distance to donation
  double calculateDistanceTo({
    required DonationModel donation,
    required double ngoLat,
    required double ngoLon,
  }) {
    return _ngoService.calculateDistance(
      lat1: ngoLat,
      lon1: ngoLon,
      lat2: donation.pickupLocation.latitude,
      lon2: donation.pickupLocation.longitude,
    );
  }

  /// Get donation by ID
  Future<Either<String, DonationModel>> getDonation(String donationId) async {
    try {
      final data = await _ngoService.getDonation(donationId);
      if (data == null) {
        return Left('Donation not found');
      }
      final donation = DonationModel.fromDatabase(data, donationId);
      return Right(donation);
    } catch (e) {
      return Left('Failed to fetch donation: ${e.toString()}');
    }
  }

  /// Get donation stream
  Stream<DonationModel?> getDonationStream(String donationId) {
    return _ngoService.getDonationStream(donationId).map((data) {
      if (data == null) return null;
      return DonationModel.fromDatabase(data, donationId);
    });
  }
}
