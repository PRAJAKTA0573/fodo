import 'package:dartz/dartz.dart';
import '../models/donation_model.dart';
import '../../../../services/donation_service.dart';
import '../../../../services/image_upload_service.dart';
import 'dart:io';

/// Donation Repository Implementation
/// Handles business logic and orchestrates services
class DonationRepositoryImpl {
  final DonationService _donationService;
  final ImageUploadService _imageUploadService;

  DonationRepositoryImpl(this._donationService, this._imageUploadService);

  /// Create new donation
  Future<Either<String, String>> createDonation(
    DonationModel donation,
  ) async {
    return await _donationService.createDonation(donation);
  }

  /// Create donation with photo upload
  Future<Either<String, String>> createDonationWithPhotos(
    DonationModel donation,
    List<File> photoFiles,
  ) async {
    try {
      // Validate images first
      final validation = _imageUploadService.validateImages(photoFiles);
      if (validation.isLeft()) {
        return Left(validation.fold((l) => l, (r) => ''));
      }

      // Create donation first to get ID
      final createResult = await _donationService.createDonation(donation);

      return await createResult.fold(
        (error) => Left(error),
        (donationId) async {
          // Upload photos
          final uploadResult = await _imageUploadService.uploadFoodPhotos(
            photoFiles,
            donationId,
          );

          return await uploadResult.fold(
            (error) async {
              // If photo upload fails, delete the donation
              await _donationService.deleteDonation(donationId);
              return Left('Photo upload failed: $error');
            },
            (photoInfoList) async {
              // Update donation with photo URLs
              final updates = {
                'foodDetails/photos': photoInfoList,
              };

              final updateResult = await _donationService.updateDonation(
                donationId,
                updates,
              );

              return updateResult.fold(
                (error) => Left('Failed to update photos: $error'),
                (_) => Right(donationId),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left('Failed to create donation: ${e.toString()}');
    }
  }

  /// Get donation by ID
  Future<Either<String, DonationModel>> getDonation(String donationId) async {
    return await _donationService.getDonation(donationId);
  }

  /// Get all donations by donor
  Future<Either<String, List<DonationModel>>> getDonationsByDonor(
    String donorId,
  ) async {
    return await _donationService.getDonationsByDonor(donorId);
  }

  /// Get active donations
  Future<Either<String, List<DonationModel>>> getActiveDonations(
    String donorId,
  ) async {
    return await _donationService.getActiveDonations(donorId);
  }

  /// Get donations by status
  Future<Either<String, List<DonationModel>>> getDonationsByStatus(
    String donorId,
    String status,
  ) async {
    return await _donationService.getDonationsByStatus(donorId, status);
  }

  /// Update donation status
  Future<Either<String, void>> updateDonationStatus(
    String donationId,
    String newStatus,
  ) async {
    return await _donationService.updateDonationStatus(donationId, newStatus);
  }

  /// Cancel donation
  Future<Either<String, void>> cancelDonation(
    String donationId,
    String reason,
  ) async {
    // Business rule: Can only cancel if not yet collected
    final donationResult = await _donationService.getDonation(donationId);

    return await donationResult.fold(
      (error) => Left(error),
      (donation) async {
        // Check if cancellation is allowed
        final nonCancellableStatuses = [
          'collected',
          'distributed',
          'completed',
          'cancelled'
        ];

        if (nonCancellableStatuses.contains(donation.status.value)) {
          return Left(
            'Cannot cancel donation with status: ${donation.status.displayName}',
          );
        }

        return await _donationService.cancelDonation(donationId, reason);
      },
    );
  }

  /// Add rating to donation
  Future<Either<String, void>> rateDonation(
    String donationId,
    double rating,
    String? comment,
  ) async {
    // Business rule: Can only rate completed donations
    final donationResult = await _donationService.getDonation(donationId);

    return await donationResult.fold(
      (error) => Left(error),
      (donation) async {
        if (donation.status.value != 'completed') {
          return const Left('Can only rate completed donations');
        }

        if (donation.rating != null) {
          return const Left('Donation has already been rated');
        }

        return await _donationService.addRating(donationId, rating, comment);
      },
    );
  }

  /// Delete donation
  Future<Either<String, void>> deleteDonation(String donationId) async {
    // Get donation to check status
    final donationResult = await _donationService.getDonation(donationId);

    return await donationResult.fold(
      (error) => Left(error),
      (donation) async {
        // Business rule: Can only delete if created or cancelled
        if (!['created', 'cancelled'].contains(donation.status.value)) {
          return const Left('Can only delete created or cancelled donations');
        }

        // Delete photos if any
        if (donation.foodDetails.photos.isNotEmpty) {
          final photoUrls = donation.foodDetails.photos.map((p) => p.url).toList();
          final thumbnailUrls = donation.foodDetails.photos.map((p) => p.thumbnailUrl).toList();
          
          await _imageUploadService.deleteMultipleImages([...photoUrls, ...thumbnailUrls]);
        }

        return await _donationService.deleteDonation(donationId);
      },
    );
  }

  /// Get donation statistics
  Future<Either<String, Map<String, int>>> getDonationStatistics(
    String donorId,
  ) async {
    return await _donationService.getDonationStatistics(donorId);
  }

  /// Get donation count
  Future<Either<String, int>> getDonationCount(String donorId) async {
    return await _donationService.getDonationCount(donorId);
  }

  /// Listen to donation changes
  Stream<DonationModel?> listenToDonation(String donationId) {
    return _donationService.listenToDonation(donationId);
  }

  /// Listen to all donations by donor
  Stream<List<DonationModel>> listenToDonationsByDonor(String donorId) {
    return _donationService.listenToDonationsByDonor(donorId);
  }
}
