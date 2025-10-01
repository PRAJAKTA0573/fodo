import 'package:dartz/dartz.dart';
import '../../../../services/firebase_auth_service.dart';
import '../../../../services/realtime_database_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Authentication Repository Implementation
class AuthRepositoryImpl {
  final FirebaseAuthService _authService;
  final RealtimeDatabaseService _dbService;

  AuthRepositoryImpl(this._authService, this._dbService);

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
      print('🔵 Starting NGO registration for: $email');
      
      // Create auth user
      print('🔵 Creating Firebase Auth user...');
      final userCredential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        print('❌ User credential is null');
        return const Left('Registration failed');
      }

      print('✅ Firebase Auth user created: ${userCredential.user!.uid}');

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
      print('🔵 Saving user to database...');
      await _dbService.setUser(user.userId, user.toDatabase());
      print('✅ User saved to database');

      // Create NGO entry with pending verification
      print('🔵 Creating NGO entry...');
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
      print('✅ NGO entry created');

      // Send email verification
      print('🔵 Sending email verification...');
      try {
        await _authService.sendEmailVerification();
        print('✅ Email verification sent');
      } catch (e) {
        print('⚠️ Email verification failed (non-fatal): $e');
      }

      print('🎉 NGO registration completed successfully!');
      return Right(user);
    } catch (e) {
      print('❌ NGO registration error: $e');
      print('❌ Error type: ${e.runtimeType}');
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
}
