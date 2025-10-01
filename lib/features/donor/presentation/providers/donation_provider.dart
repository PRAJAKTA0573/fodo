import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../data/models/donation_model.dart';
import '../../data/repositories/donation_repository_impl.dart';
import '../../../../core/constants/app_constants.dart';

/// Donation Provider - State management for donations
class DonationProvider extends ChangeNotifier {
  final DonationRepositoryImpl _repository;

  DonationProvider(this._repository);

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<DonationModel> _donations = [];
  DonationModel? _currentDonation;
  Map<String, int>? _statistics;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DonationModel> get donations => _donations;
  DonationModel? get currentDonation => _currentDonation;
  Map<String, int>? get statistics => _statistics;

  // Filter getters
  List<DonationModel> get activeDonations {
    final activeStatuses = ['created', 'visible', 'accepted', 'inTransit', 'collected'];
    return _donations.where((d) => activeStatuses.contains(d.status.value)).toList();
  }

  List<DonationModel> get completedDonations {
    return _donations.where((d) => d.status.value == 'completed').toList();
  }

  List<DonationModel> get cancelledDonations {
    return _donations.where((d) => d.status.value == 'cancelled').toList();
  }

  /// Create new donation
  Future<bool> createDonation(DonationModel donation) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.createDonation(donation);

    return result.fold(
      (error) {
        _isLoading = false;
        _errorMessage = error;
        notifyListeners();
        return false;
      },
      (donationId) {
        _isLoading = false;
        _errorMessage = null;
        // Refresh donations list
        notifyListeners();
        return true;
      },
    );
  }

  /// Create donation with photos
  Future<bool> createDonationWithPhotos(
    DonationModel donation,
    List<File> photoFiles,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.createDonationWithPhotos(
      donation,
      photoFiles,
    );

    return result.fold(
      (error) {
        _isLoading = false;
        _errorMessage = error;
        notifyListeners();
        return false;
      },
      (donationId) {
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Load all donations for a donor
  Future<void> loadDonations(String donorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getDonationsByDonor(donorId);

    result.fold(
      (error) {
        _isLoading = false;
        _errorMessage = error;
        _donations = [];
      },
      (donations) {
        _isLoading = false;
        _errorMessage = null;
        _donations = donations;
      },
    );

    notifyListeners();
  }

  /// Load single donation
  Future<void> loadDonation(String donationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getDonation(donationId);

    result.fold(
      (error) {
        _isLoading = false;
        _errorMessage = error;
        _currentDonation = null;
      },
      (donation) {
        _isLoading = false;
        _errorMessage = null;
        _currentDonation = donation;
      },
    );

    notifyListeners();
  }

  /// Load active donations only
  Future<void> loadActiveDonations(String donorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getActiveDonations(donorId);

    result.fold(
      (error) {
        _isLoading = false;
        _errorMessage = error;
        _donations = [];
      },
      (donations) {
        _isLoading = false;
        _errorMessage = null;
        _donations = donations;
      },
    );

    notifyListeners();
  }

  /// Load donations by status
  Future<void> loadDonationsByStatus(String donorId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getDonationsByStatus(donorId, status);

    result.fold(
      (error) {
        _isLoading = false;
        _errorMessage = error;
        _donations = [];
      },
      (donations) {
        _isLoading = false;
        _errorMessage = null;
        _donations = donations;
      },
    );

    notifyListeners();
  }

  /// Cancel donation
  Future<bool> cancelDonation(String donationId, String reason) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.cancelDonation(donationId, reason);

    return result.fold(
      (error) {
        _isLoading = false;
        _errorMessage = error;
        notifyListeners();
        return false;
      },
      (_) {
        _isLoading = false;
        _errorMessage = null;
        // Update local donation if it's the current one
        if (_currentDonation?.donationId == donationId) {
          _currentDonation = _currentDonation?.copyWith(
            status: DonationStatus.cancelled,
            cancellationReason: reason,
          );
        }
        // Update in list
        final index = _donations.indexWhere((d) => d.donationId == donationId);
        if (index != -1) {
          _donations[index] = _donations[index].copyWith(
            status: DonationStatus.cancelled,
            cancellationReason: reason,
          );
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Rate donation
  Future<bool> rateDonation(
    String donationId,
    double rating,
    String? comment,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.rateDonation(
      donationId,
      rating,
      comment,
    );

    return result.fold(
      (error) {
        _isLoading = false;
        _errorMessage = error;
        notifyListeners();
        return false;
      },
      (_) {
        _isLoading = false;
        _errorMessage = null;
        // Update local donation
        if (_currentDonation?.donationId == donationId) {
          _currentDonation = _currentDonation?.copyWith(
            rating: Rating(
              rating: rating,
              comment: comment,
              ratedAt: DateTime.now(),
            ),
          );
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Delete donation
  Future<bool> deleteDonation(String donationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.deleteDonation(donationId);

    return result.fold(
      (error) {
        _isLoading = false;
        _errorMessage = error;
        notifyListeners();
        return false;
      },
      (_) {
        _isLoading = false;
        _errorMessage = null;
        // Remove from local list
        _donations.removeWhere((d) => d.donationId == donationId);
        if (_currentDonation?.donationId == donationId) {
          _currentDonation = null;
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Load statistics
  Future<void> loadStatistics(String donorId) async {
    final result = await _repository.getDonationStatistics(donorId);

    result.fold(
      (error) {
        _errorMessage = error;
        _statistics = null;
      },
      (stats) {
        _statistics = stats;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Listen to donation changes (real-time)
  void listenToDonation(String donationId) {
    _repository.listenToDonation(donationId).listen(
      (donation) {
        if (donation != null) {
          _currentDonation = donation;
          // Update in list if present
          final index = _donations.indexWhere((d) => d.donationId == donationId);
          if (index != -1) {
            _donations[index] = donation;
          }
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Listen to all donations (real-time)
  void listenToDonations(String donorId) {
    _repository.listenToDonationsByDonor(donorId).listen(
      (donations) {
        _donations = donations;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _donations = [];
    _currentDonation = null;
    _statistics = null;
    notifyListeners();
  }

  /// Get donation by ID from local list
  DonationModel? getDonationById(String donationId) {
    try {
      return _donations.firstWhere((d) => d.donationId == donationId);
    } catch (e) {
      return null;
    }
  }

  /// Get donations count
  int get totalDonations => _donations.length;
  int get activeCount => activeDonations.length;
  int get completedCount => completedDonations.length;
  int get cancelledCount => cancelledDonations.length;

  /// Check if there are any donations
  bool get hasDonations => _donations.isNotEmpty;
  bool get hasActiveDonations => activeDonations.isNotEmpty;
}
