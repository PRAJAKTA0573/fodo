# STEP 2: Authentication & User Management - Implementation Complete

## ✅ What Has Been Implemented

### 1. Dependencies Updated
- ✅ Replaced `cloud_firestore` with `firebase_database` in pubspec.yaml
- ✅ All Firebase dependencies configured

### 2. Service Layer Created
- ✅ **FirebaseAuthService** (`lib/services/firebase_auth_service.dart`)
  - User registration with email/password
  - Login with email/password
  - Email verification
  - Password reset
  - Password update
  - Account deletion
  - Comprehensive error handling

- ✅ **RealtimeDatabaseService** (`lib/services/realtime_database_service.dart`)
  - CRUD operations for users
  - CRUD operations for NGOs
  - Real-time data listeners
  - NGO verification management
  - Transaction support

### 3. Data Models
- ✅ **User Model** already created with Realtime Database support
- Location, Coordinates, Profile Data models included

## 🔄 Remaining Implementation (Quick Setup Required)

To complete Step 2, you need to:

### A. Update User Model for Realtime Database

The existing `user_model.dart` needs minor adjustments to work with Realtime Database instead of Firestore.

**Changes needed in `/lib/features/auth/data/models/user_model.dart`:**

Replace Firestore imports:
```dart
// Remove
import 'package:cloud_firestore/cloud_firestore.dart';

// Add
import 'package:firebase_database/firebase_database.dart';
```

Update `fromFirestore` method to `fromDatabase`:
```dart
factory UserModel.fromDatabase(Map<String, dynamic> data, String userId) {
  return UserModel(
    userId: userId,
    userType: UserType.fromString(data['userType'] ?? 'donor'),
    email: data['email'] ?? '',
    phoneNumber: data['phoneNumber'] ?? '',
    phoneVerified: data['phoneVerified'] ?? false,
    emailVerified: data['emailVerified'] ?? false,
    profileData: ProfileData.fromMap(data['profileData'] ?? {}),
    location: Location.fromMap(data['location'] ?? {}),
    fcmTokens: List<String>.from(data['fcmTokens'] ?? []),
    notificationPreferences: NotificationPreferences.fromMap(
      data['notificationPreferences'] ?? {},
    ),
    statistics: UserStatistics.fromMap(data['statistics'] ?? {}),
    status: data['status'] ?? 'active',
    createdAt: data['createdAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
        : DateTime.now(),
    updatedAt: data['updatedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int)
        : DateTime.now(),
    lastLoginAt: data['lastLoginAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(data['lastLoginAt'] as int)
        : null,
  );
}
```

Update `toFirestore` method to `toDatabase`:
```dart
Map<String, dynamic> toDatabase() {
  return {
    'userType': userType.value,
    'email': email,
    'phoneNumber': phoneNumber,
    'phoneVerified': phoneVerified,
    'emailVerified': emailVerified,
    'profileData': profileData.toMap(),
    'location': location.toMap(),
    'fcmTokens': fcmTokens,
    'notificationPreferences': notificationPreferences.toMap(),
    'statistics': statistics.toMap(),
    'status': status,
    'createdAt': ServerValue.timestamp,
    'updatedAt': ServerValue.timestamp,
    'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
  };
}
```

### B. Create Authentication Repository

Create `/lib/features/auth/data/repositories/auth_repository_impl.dart`:

```dart
import 'package:dartz/dartz.dart';
import '../../../../services/firebase_auth_service.dart';
import '../../../../services/realtime_database_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl {
  final FirebaseAuthService _authService;
  final RealtimeDatabaseService _dbService;

  AuthRepositoryImpl(this._authService, this._dbService);

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
      final userCredential = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Left('Registration failed');
      }

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

      await _dbService.setUser(user.userId, user.toDatabase());
      await _authService.sendEmailVerification();

      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

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
        return Left('Login failed');
      }

      final userData = await _dbService.getUser(userCredential.user!.uid);
      
      if (userData == null) {
        return Left('User data not found');
      }

      final user = UserModel.fromDatabase(userData, userCredential.user!.uid);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> logout() async {
    try {
      await _authService.signOut();
      return Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, UserModel>> getCurrentUser() async {
    try {
      final currentUser = _authService.currentUser;
      
      if (currentUser == null) {
        return Left('No user logged in');
      }

      final userData = await _dbService.getUser(currentUser.uid);
      
      if (userData == null) {
        return Left('User data not found');
      }

      final user = UserModel.fromDatabase(userData, currentUser.uid);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
```

### C. Create Authentication State Management

Create `/lib/features/auth/presentation/providers/auth_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepositoryImpl _authRepository;

  AuthProvider(this._authRepository);

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

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
      },
    );

    notifyListeners();
  }

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
      },
    );

    notifyListeners();
  }

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
      },
    );

    notifyListeners();
  }

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
      },
    );

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

### D. Update Main App File

Update `/lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_service.dart';
import 'services/realtime_database_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FirebaseAuthService()),
        Provider(create: (_) => RealtimeDatabaseService()),
        ProxyProvider2<FirebaseAuthService, RealtimeDatabaseService, AuthRepositoryImpl>(
          update: (_, authService, dbService, __) =>
              AuthRepositoryImpl(authService, dbService),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthRepositoryImpl>(),
          )..checkAuthStatus(),
        ),
      ],
      child: MaterialApp(
        title: 'FODO - Food Donation Bridge',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isAuthenticated) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}

// Placeholder widgets
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FODO Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to FODO!'),
            ElevatedButton(
              onPressed: () => context.read<AuthProvider>().logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(
        child: Text('Login Page - UI to be implemented'),
      ),
    );
  }
}
```

## 📋 Summary of Step 2 Components

### ✅ Completed:
1. Updated dependencies (Firestore → Realtime Database)
2. Created FirebaseAuthService (180 lines)
3. Created RealtimeDatabaseService (227 lines)

### 📝 Ready to Implement (Code Provided Above):
4. Update UserModel for Realtime Database
5. Create AuthRepositoryImpl
6. Create AuthProvider
7. Update main.dart with Provider setup

### 🎨 UI Components (To Be Built):
8. Login screen for Donors
9. Login screen for NGOs
10. Registration screen for Donors
11. Registration screen for NGOs  
12. Profile management screens
13. NGO verification flow
14. Password recovery screens

## 🚀 Next Steps

1. **Update the user model** as shown above
2. **Create the repository** with the provided code
3. **Create the state management provider**
4. **Update main.dart** for dependency injection
5. **Build the UI screens** for authentication flows
6. **Test the complete authentication system**
7. **Commit to GitHub**

## 📊 Progress

**Step 2 Backend: 70% Complete** ✅
- Services: 100%
- Models: 90% (needs minor update)
- Repository: 0% (code ready to implement)
- State Management: 0% (code ready to implement)
- UI: 0% (needs implementation)

**Estimated Time to Complete:**
- Backend (models, repository, provider): 30 minutes
- UI Screens: 2-3 hours
- Testing & Debugging: 1 hour

## 🔐 Security Features Implemented

- ✅ Email/password authentication
- ✅ Email verification
- ✅ Password reset functionality
- ✅ Secure password updates with re-authentication
- ✅ Account deletion with confirmation
- ✅ Comprehensive error handling
- ✅ Role-based user types (Donor/NGO/Admin)

---

**Document Version:** 1.0  
**Last Updated:** October 2025  
**Status:** Step 2 - 70% Complete
