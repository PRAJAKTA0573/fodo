import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Authentication states
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Authentication Provider
/// Manages authentication state and operations
class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _authRepository;

  AuthProvider(this._authRepository);

  // State variables
  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _isEmailVerified = false;

  // Getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isEmailVerified => _isEmailVerified;
  bool get isDonor => _currentUser?.userType == UserType.donor;
  bool get isNGO => _currentUser?.userType == UserType.ngo;

  /// Login with email and password
  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    result.fold(
      (error) {
        _status = AuthStatus.error;
        _errorMessage = error;
        _currentUser = null;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _currentUser = user;
        _errorMessage = null;
        _checkEmailVerification();
      },
    );

    notifyListeners();
  }

  /// Register a new donor
  Future<void> registerDonor({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
    String? organizationName,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.registerDonor(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
      organizationName: organizationName,
    );

    result.fold(
      (error) {
        _status = AuthStatus.error;
        _errorMessage = error;
        _currentUser = null;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _currentUser = user;
        _errorMessage = null;
        _isEmailVerified = false;
      },
    );

    notifyListeners();
  }

  /// Register a new NGO
  Future<void> registerNGO({
    required String ngoName,
    required String registrationNumber,
    required String email,
    required String phoneNumber,
    required String password,
    required String contactPersonName,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.registerNGO(
      ngoName: ngoName,
      registrationNumber: registrationNumber,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      contactPersonName: contactPersonName,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
    );

    result.fold(
      (error) {
        _status = AuthStatus.error;
        _errorMessage = error;
        _currentUser = null;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _currentUser = user;
        _errorMessage = null;
        _isEmailVerified = false;
      },
    );

    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await _authRepository.logout();

    result.fold(
      (error) {
        _status = AuthStatus.error;
        _errorMessage = error;
      },
      (_) {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
        _errorMessage = null;
        _isEmailVerified = false;
      },
    );

    notifyListeners();
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.sendPasswordResetEmail(email);

    result.fold(
      (error) {
        _status = AuthStatus.error;
        _errorMessage = error;
      },
      (_) {
        _status = AuthStatus.initial;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Update password
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.fold(
      (error) {
        _errorMessage = error;
        notifyListeners();
        return false;
      },
      (_) {
        notifyListeners();
        return true;
      },
    );
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    if (_currentUser == null) return false;

    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.updateProfile(
      userId: _currentUser!.userId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
    );

    return result.fold(
      (error) {
        _errorMessage = error;
        notifyListeners();
        return false;
      },
      (updatedUser) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      },
    );
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    final result = await _authRepository.getCurrentUser();

    result.fold(
      (error) {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _currentUser = user;
        _checkEmailVerification();
      },
    );

    notifyListeners();
  }

  /// Check email verification status
  Future<void> _checkEmailVerification() async {
    final result = await _authRepository.isEmailVerified();
    result.fold(
      (_) => _isEmailVerified = false,
      (verified) => _isEmailVerified = verified,
    );
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    _errorMessage = null;
    
    final result = await _authRepository.resendEmailVerification();

    result.fold(
      (error) {
        _errorMessage = error;
      },
      (_) {
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Refresh email verification status
  Future<void> refreshEmailVerification() async {
    await _checkEmailVerification();
    notifyListeners();
  }

  /// Delete account
  Future<bool> deleteAccount(String password) async {
    _errorMessage = null;

    final result = await _authRepository.deleteAccount(password);

    return result.fold(
      (error) {
        _errorMessage = error;
        notifyListeners();
        return false;
      },
      (_) {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
        _errorMessage = null;
        _isEmailVerified = false;
        notifyListeners();
        return true;
      },
    );
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    final result = await _authRepository.getCurrentUser();

    result.fold(
      (_) {}, // Ignore error, keep current user
      (user) {
        _currentUser = user;
        notifyListeners();
      },
    );
  }
}
