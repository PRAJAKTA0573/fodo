import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../../../../services/firebase_auth_service.dart';
import '../../../../services/realtime_database_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Authentication Repository Implementation
class AuthRepositoryImpl {
  final FirebaseAuthService _authService;
  final RealtimeDatabaseService _dbService;
  final Logger _logger = Logger();

  AuthRepositoryImpl(this._authService, this._dbService);

  /// Sign in with Google
  Future<Either<String, UserModel>> signInWithGoogle() async {
    try {
      _logger.i('Starting Google Sign-In...');
      
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential.user == null) {
        return const Left('Google sign in failed');
      }
      
      _logger.i('Google sign in successful: ${userCredential.user!.uid}');
      
      // Check if user exists in database
      final userData = await _dbService.getUser(userCredential.user!.uid);
      
      if (userData != null) {
        // Existing user - login
        _logger.i('Existing user found');
        final user = UserModel.fromDatabase(userData, userCredential.user!.uid);
        return Right(user);
      } else {
        // New user - return null to trigger registration flow
        _logger.i('New user - needs to complete registration');
        return const Left('NEW_USER');
      }
    } catch (e) {
      _logger.e('Google sign in error: $e');
      return Left(e.toString());
    }
  }

  /// Complete Google Sign-In registration for Donor
  Future<Either<String, UserModel>> completeGoogleSignInDonor({
    required String userId,
    required String email,
    required String displayName,
    required String phoneNumber,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
    String? organizationName,
  }) async {
    try {
      _logger.i('Completing donor registration for Google user: $userId');
      
      // Create user model
      final user = UserModel(
        userId: userId,
        userType: UserType.donor,
        email: email,
        phoneNumber: phoneNumber,
        profileData: ProfileData(
          fullName: displayName,
          organizationName: organizationName,
        ),
        location: Location(
          address: address,
          city: city,
          state: state,
          pincode: pincode,
          coordinates: Coordinates(
            latitude: latitude,
            longitude: longitude,
          ),
        ),
        notificationPreferences: NotificationPreferences(),
        statistics: UserStatistics(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await _dbService.setUser(user.userId, user.toDatabase());
      _logger.i('Donor registration completed');
      
      return Right(user);
    } catch (e) {
      _logger.e('Complete donor registration error: $e');
      return Left(e.toString());
    }
  }

  /// Complete Google Sign-In registration for NGO
  Future<Either<String, UserModel>> completeGoogleSignInNGO({
    required String userId,
    required String email,
    required String displayName,
    required String ngoName,
    required String registrationNumber,
    required String phoneNumber,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
  }) async {
    try {
      _logger.i('Completing NGO registration for Google user: $userId');
      
      // Create user model
      final user = UserModel(
        userId: userId,
        userType: UserType.ngo,
        email: email,
        phoneNumber: phoneNumber,
        profileData: ProfileData(
          fullName: displayName,
          organizationName: ngoName,
        ),
        location: Location(
          address: address,
          city: city,
          state: state,
          pincode: pincode,
          coordinates: Coordinates(
            latitude: latitude,
            longitude: longitude,
          ),
        ),
        notificationPreferences: NotificationPreferences(),
        statistics: UserStatistics(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user to database
      await _dbService.setUser(user.userId, user.toDatabase());

      // Create NGO entry with pending verification
      await _dbService.setNGO(user.userId, {
        'ngoName': ngoName,
        'registrationNumber': registrationNumber,
        'verification': {
          'status': 'pending',
          'submittedAt': DateTime.now().millisecondsSinceEpoch,
        },
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      _logger.i('NGO registration completed');
      return Right(user);
    } catch (e) {
      _logger.e('Complete NGO registration error: $e');
      return Left(e.toString());
    }
  }

  /// Register a new donor
  Future<Either<String, UserModel>> registerDonor({
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
    try {
      // Create auth user
      final userCredential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return const Left('Registration failed');
      }

      // Create user model
      final user = UserModel(
        userId: userCredential.user!.uid,
        userType: UserType.donor,
        email: email,
        phoneNumber: phoneNumber,
        profileData: ProfileData(
          fullName: fullName,
          organizationName: organizationName,
        ),
        location: Location(
          address: address,
          city: city,
          state: state,
          pincode: pincode,
          coordinates: Coordinates(
            latitude: latitude,
            longitude: longitude,
          ),
        ),
        notificationPreferences: NotificationPreferences(),
        statistics: UserStatistics(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await _dbService.setUser(user.userId, user.toDatabase());
      
      // Send email verification
      await _authService.sendEmailVerification();

      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Register a new NGO
  Future<Either<String, UserModel>> registerNGO({
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
    try {
      _logger.i('Starting NGO registration for: $email');
      
      // Create auth user
      _logger.i('Creating Firebase Auth user...');
      final userCredential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        _logger.e('User credential is null');
        return const Left('Registration failed');
      }

      _logger.i('Firebase Auth user created: ${userCredential.user!.uid}');

      // Create user model
      final user = UserModel(
        userId: userCredential.user!.uid,
        userType: UserType.ngo,
        email: email,
        phoneNumber: phoneNumber,
        profileData: ProfileData(
          fullName: contactPersonName,
          organizationName: ngoName,
        ),
        location: Location(
          address: address,
          city: city,
          state: state,
          pincode: pincode,
          coordinates: Coordinates(
            latitude: latitude,
            longitude: longitude,
          ),
        ),
        notificationPreferences: NotificationPreferences(),
        statistics: UserStatistics(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user to database
      _logger.i('Saving user to database...');
      await _dbService.setUser(user.userId, user.toDatabase());
      _logger.i('User saved to database');

      // Create NGO entry with pending verification
      _logger.i('Creating NGO entry...');
      await _dbService.setNGO(user.userId, {
        'ngoName': ngoName,
        'registrationNumber': registrationNumber,
        'verification': {
          'status': 'pending',
          'submittedAt': DateTime.now().millisecondsSinceEpoch,
        },
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      _logger.i('NGO entry created');

      // Send email verification
      _logger.i('Sending email verification...');
      try {
        await _authService.sendEmailVerification();
        _logger.i('Email verification sent');
      } catch (e) {
        _logger.w('Email verification failed (non-fatal): $e');
      }

      _logger.i('NGO registration completed successfully!');
      return Right(user);
    } catch (e) {
      _logger.e('NGO registration error: $e');
      _logger.e('Error type: ${e.runtimeType}');
      return Left('Registration failed: ${e.toString()}');
    }
  }

  /// Login user
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _authService.loginWithEmail(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return const Left('Login failed');
      }

      final userData = await _dbService.getUser(userCredential.user!.uid);

      if (userData == null) {
        return const Left('User data not found');
      }

      final user = UserModel.fromDatabase(userData, userCredential.user!.uid);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Send password reset email
  Future<Either<String, void>> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Update password
  Future<Either<String, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Logout
  Future<Either<String, void>> logout() async {
    try {
      await _authService.signOut();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Get current user
  Future<Either<String, UserModel>> getCurrentUser() async {
    try {
      final currentUser = _authService.currentUser;

      if (currentUser == null) {
        return const Left('No user logged in');
      }

      final userData = await _dbService.getUser(currentUser.uid);

      if (userData == null) {
        return const Left('User data not found');
      }

      final user = UserModel.fromDatabase(userData, currentUser.uid);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Check if email is verified
  Future<Either<String, bool>> isEmailVerified() async {
    try {
      final isVerified = await _authService.isEmailVerified();
      return Right(isVerified);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Resend email verification
  Future<Either<String, void>> resendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Update user profile
  Future<Either<String, UserModel>> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) {
        updates['profileData/fullName'] = fullName;
      }
      if (phoneNumber != null) {
        updates['phoneNumber'] = phoneNumber;
      }
      if (address != null) {
        updates['location/address'] = address;
      }
      if (city != null) {
        updates['location/city'] = city;
      }
      if (state != null) {
        updates['location/state'] = state;
      }
      if (pincode != null) {
        updates['location/pincode'] = pincode;
      }

      await _dbService.updateUser(userId, updates);

      // Get updated user
      final userData = await _dbService.getUser(userId);
      if (userData == null) {
        return const Left('Failed to fetch updated user');
      }

      final user = UserModel.fromDatabase(userData, userId);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Delete account
  Future<Either<String, void>> deleteAccount(String password) async {
    try {
      await _authService.deleteAccount(password);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Update user type (for role switching)
  Future<Either<String, UserModel>> updateUserType({
    required String userId,
    required UserType userType,
  }) async {
    try {
      _logger.i('Updating user type to: ${userType.value}');
      
      await _dbService.updateUser(userId, {
        'userType': userType.value,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Get updated user
      final userData = await _dbService.getUser(userId);
      if (userData == null) {
        return const Left('Failed to fetch updated user');
      }

      final user = UserModel.fromDatabase(userData, userId);
      _logger.i('User type updated successfully');
      return Right(user);
    } catch (e) {
      _logger.e('Update user type error: $e');
      return Left(e.toString());
    }
  }
}
