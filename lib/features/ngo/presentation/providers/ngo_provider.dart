import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../data/repositories/ngo_repository_impl.dart';
import '../../data/models/ngo_model.dart';
import '../../../donor/data/models/donation_model.dart';

/// NGO Provider - State management for all NGO features
class NGOProvider extends ChangeNotifier {
  final NGORepositoryImpl _repository;
  final String ngoId;

  NGOProvider(this._repository, this.ngoId) {
    _init();
  }

  // State variables
  NGOModel? _ngo;
  List<DonationModel> _availableDonations = [];
  List<DonationModel> _activePickups = [];
  List<DonationModel> _collectionHistory = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filters
  String _searchQuery = '';
  String _selectedFoodType = 'All';
  double _maxDistance = 50.0; // km
  String _sortBy = 'distance'; // distance, time, quantity

  // Stream subscriptions
  StreamSubscription? _availableDonationsSubscription;
  StreamSubscription? _activePickupsSubscription;

  // Getters
  NGOModel? get ngo => _ngo;
  List<DonationModel> get availableDonations => _getFilteredDonations();
  List<DonationModel> get activePickups => _activePickups;
  List<DonationModel> get collectionHistory => _collectionHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedFoodType => _selectedFoodType;
  double get maxDistance => _maxDistance;
  String get sortBy => _sortBy;

  // Statistics
  int get totalCollections => _ngo?.statistics.totalCollections ?? 0;
  int get totalPeopleFed => _ngo?.statistics.totalPeopleFed ?? 0;
  int get completedCollections => _ngo?.statistics.completedCollections ?? 0;
  double get rating => _ngo?.statistics.rating ?? 0.0;
  int get activePickupsCount => _activePickups.length;
  int get availableCount => _availableDonations.length;

  /// Initialize provider
  void _init() {
    loadNGO();
    _setupRealTimeListeners();
  }

  /// Load NGO details
  Future<void> loadNGO() async {
    try {
      final result = await _repository.getNGO(ngoId);
      result.fold(
        (error) => _errorMessage = error,
        (ngo) {
          _ngo = ngo;
          _errorMessage = null;
        },
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load NGO: $e';
      notifyListeners();
    }
  }

  /// Setup real-time listeners
  void _setupRealTimeListeners() {
    // Listen to available donations
    _availableDonationsSubscription = _repository
        .getAvailableDonationsStream()
        .listen((donations) {
      _availableDonations = donations;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Stream error: $error';
      notifyListeners();
    });

    // Listen to active pickups
    _activePickupsSubscription = _repository
        .getActivePickupsStream(ngoId)
        .listen((pickups) {
      _activePickups = pickups;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Stream error: $error';
      notifyListeners();
    });
  }

  /// Load collection history
  Future<void> loadCollectionHistory() async {
    _isLoading = true;
    notifyListeners();

    final result = await _repository.getCollectionHistory(ngoId);
    result.fold(
      (error) => _errorMessage = error,
      (history) {
        _collectionHistory = history;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await loadNGO();
    await loadCollectionHistory();
  }

  /// Get filtered donations based on search, filters, and sort
  List<DonationModel> _getFilteredDonations() {
    List<DonationModel> filtered = List.from(_availableDonations);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((donation) {
        final query = _searchQuery.toLowerCase();
        return donation.foodDetails.description.toLowerCase().contains(query) ||
            donation.foodDetails.foodType.value.toLowerCase().contains(query) ||
            donation.pickupLocation.city.toLowerCase().contains(query);
      }).toList();
    }

    // Apply food type filter
    if (_selectedFoodType != 'All') {
      filtered = filtered.where((donation) {
        return donation.foodDetails.foodType.value == _selectedFoodType;
      }).toList();
    }

    // Apply distance filter
    if (_ngo != null) {
      filtered = _repository.filterByDistance(
        donations: filtered,
        ngoLat: _ngo!.location.coordinates.latitude,
        ngoLon: _ngo!.location.coordinates.longitude,
        maxDistanceKm: _maxDistance,
      );
    }

    // Apply sorting
    if (_ngo != null) {
      if (_sortBy == 'distance') {
        filtered = _repository.sortByDistance(
          donations: filtered,
          ngoLat: _ngo!.location.coordinates.latitude,
          ngoLon: _ngo!.location.coordinates.longitude,
        );
      } else if (_sortBy == 'time') {
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (_sortBy == 'quantity') {
        filtered.sort((a, b) => 
          b.foodDetails.estimatedPeopleFed.compareTo(a.foodDetails.estimatedPeopleFed)
        );
      }
    }

    return filtered;
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Update food type filter
  void updateFoodTypeFilter(String foodType) {
    _selectedFoodType = foodType;
    notifyListeners();
  }

  /// Update max distance filter
  void updateMaxDistance(double distance) {
    _maxDistance = distance;
    notifyListeners();
  }

  /// Update sort by
  void updateSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedFoodType = 'All';
    _maxDistance = 50.0;
    _sortBy = 'distance';
    notifyListeners();
  }

  /// Accept a donation
  Future<bool> acceptDonation({
    required String donationId,
    required String estimatedPickupTime,
  }) async {
    if (_ngo == null) {
      _errorMessage = 'NGO data not loaded';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.acceptDonation(
      donationId: donationId,
      ngoId: ngoId,
      ngoName: _ngo!.ngoName,
      estimatedPickupTime: estimatedPickupTime,
    );

    _isLoading = false;
    
    result.fold(
      (error) {
        _errorMessage = error;
        notifyListeners();
        return false;
      },
      (_) {
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );

    return result.isRight();
  }

  /// Mark donation as on the way
  Future<bool> markOnTheWay(String donationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.markOnTheWay(donationId);

    _isLoading = false;
    result.fold(
      (error) => _errorMessage = error,
      (_) => _errorMessage = null,
    );
    notifyListeners();

    return result.isRight();
  }

  /// Mark donation as reached
  Future<bool> markReached(String donationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.markReached(donationId);

    _isLoading = false;
    result.fold(
      (error) => _errorMessage = error,
      (_) => _errorMessage = null,
    );
    notifyListeners();

    return result.isRight();
  }

  /// Mark donation as collected
  Future<bool> markCollected({
    required String donationId,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.markCollected(
      donationId: donationId,
      notes: notes,
    );

    _isLoading = false;
    result.fold(
      (error) => _errorMessage = error,
      (_) => _errorMessage = null,
    );
    notifyListeners();

    return result.isRight();
  }

  /// Mark donation as distributed
  Future<bool> markDistributed({
    required String donationId,
    required int beneficiariesCount,
    List<String>? distributionPhotos,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.markDistributed(
      donationId: donationId,
      beneficiariesCount: beneficiariesCount,
      distributionPhotos: distributionPhotos,
      notes: notes,
    );

    _isLoading = false;
    result.fold(
      (error) => _errorMessage = error,
      (_) => _errorMessage = null,
    );
    notifyListeners();

    return result.isRight();
  }

  /// Complete donation
  Future<bool> completeDonation({
    required String donationId,
    required int beneficiariesCount,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.completeDonation(
      donationId: donationId,
      ngoId: ngoId,
      beneficiariesCount: beneficiariesCount,
    );

    _isLoading = false;
    result.fold(
      (error) => _errorMessage = error,
      (_) {
        _errorMessage = null;
        // Reload NGO to update statistics
        loadNGO();
      },
    );
    notifyListeners();

    return result.isRight();
  }

  /// Calculate distance to donation
  double? getDistanceTo(DonationModel donation) {
    if (_ngo == null) return null;
    return _repository.calculateDistanceTo(
      donation: donation,
      ngoLat: _ngo!.location.coordinates.latitude,
      ngoLon: _ngo!.location.coordinates.longitude,
    );
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _availableDonationsSubscription?.cancel();
    _activePickupsSubscription?.cancel();
    super.dispose();
  }
}
