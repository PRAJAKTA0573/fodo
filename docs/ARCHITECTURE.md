# FODO - Architecture Documentation

## Overview

This document outlines the technical architecture, design patterns, and structural decisions for the FODO (Food Donation Bridge) application.

---

## Architecture Pattern

### Clean Architecture + Feature-First Structure

We follow **Clean Architecture** principles combined with a **feature-first** folder structure. This approach provides:

- **Separation of Concerns**: Business logic is independent of UI and external frameworks
- **Testability**: Each layer can be tested independently
- **Maintainability**: Easy to locate and modify code related to specific features
- **Scalability**: New features can be added without affecting existing code

### Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│         (UI, Widgets, Pages, State Management)           │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                    Domain Layer                          │
│         (Entities, Use Cases, Repositories)              │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                     Data Layer                           │
│     (Models, Repositories Impl, Data Sources)            │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                 External Services                        │
│       (Firebase, APIs, Local Storage, etc.)              │
└─────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
fodo/
├── lib/
│   ├── main.dart                     # App entry point
│   ├── app.dart                      # App widget configuration
│   │
│   ├── core/                         # Core utilities & shared code
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # App-wide constants
│   │   │   ├── api_constants.dart    # API endpoints
│   │   │   └── route_constants.dart  # Navigation routes
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # Theme configuration
│   │   │   ├── colors.dart           # Color palette
│   │   │   └── text_styles.dart      # Typography
│   │   ├── utils/
│   │   │   ├── validators.dart       # Input validators
│   │   │   ├── date_helper.dart      # Date utilities
│   │   │   └── location_helper.dart  # Location utilities
│   │   └── errors/
│   │       └── exceptions.dart       # Custom exceptions
│   │
│   ├── features/                     # Feature modules
│   │   ├── auth/                     # Authentication feature
│   │   │   ├── data/
│   │   │   │   ├── models/           # Data transfer objects
│   │   │   │   ├── repositories/     # Repository implementations
│   │   │   │   └── datasources/      # Remote & local data sources
│   │   │   ├── domain/
│   │   │   │   ├── entities/         # Business entities
│   │   │   │   ├── repositories/     # Repository interfaces
│   │   │   │   └── usecases/         # Business logic
│   │   │   └── presentation/
│   │   │       ├── pages/            # Screen widgets
│   │   │       ├── widgets/          # Feature-specific widgets
│   │   │       └── providers/        # State management
│   │   │
│   │   ├── donor/                    # Donor feature
│   │   ├── ngo/                      # NGO feature
│   │   └── shared/                   # Shared across features
│   │
│   └── services/                     # Global services
│       ├── firebase_service.dart
│       ├── location_service.dart
│       ├── notification_service.dart
│       └── storage_service.dart
│
├── assets/                           # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/                             # Test files
│   ├── unit/
│   ├── widget/
│   └── integration/
│
└── docs/                             # Documentation
    ├── PROJECT_OVERVIEW.md
    ├── DATABASE_SCHEMA.md
    ├── API_DOCUMENTATION.md
    └── ARCHITECTURE.md
```

---

## Layer Responsibilities

### 1. Presentation Layer

**Purpose**: Handle UI rendering and user interactions

**Components**:
- **Pages**: Full-screen views
- **Widgets**: Reusable UI components
- **Providers**: State management (using Provider/Riverpod)

**Rules**:
- No direct access to data sources
- No business logic
- Only calls use cases from domain layer
- Handles UI state and user input

**Example**:
```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // UI code
  }
}
```

### 2. Domain Layer

**Purpose**: Contains business logic and rules

**Components**:
- **Entities**: Pure Dart objects representing business concepts
- **Use Cases**: Single-purpose business operations
- **Repository Interfaces**: Contracts for data access

**Rules**:
- No dependency on external frameworks
- Pure Dart code only
- Defines interfaces, not implementations
- Independent of UI and data sources

**Example**:
```dart
class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<Either<Failure, User>> call(String email, String password) {
    return repository.login(email, password);
  }
}
```

### 3. Data Layer

**Purpose**: Manage data from various sources

**Components**:
- **Models**: Data transfer objects with serialization
- **Repository Implementations**: Concrete implementations of domain interfaces
- **Data Sources**: Remote (API) and Local (Cache) data access

**Rules**:
- Implements domain repository interfaces
- Handles data transformation (Model ↔ Entity)
- Manages caching strategy
- Handles API calls and local storage

**Example**:
```dart
class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
```

---

## Design Patterns

### 1. Repository Pattern

Abstracts data access logic from business logic.

```dart
// Domain - Interface
abstract class DonationRepository {
  Future<List<Donation>> getNearbyDonations(double lat, double lng);
  Future<void> createDonation(Donation donation);
}

// Data - Implementation
class DonationRepositoryImpl implements DonationRepository {
  final FirebaseFirestore firestore;
  
  @override
  Future<List<Donation>> getNearbyDonations(double lat, double lng) {
    // Implementation
  }
}
```

### 2. Use Case Pattern

Encapsulates single business operations.

```dart
class GetNearbyDonationsUseCase {
  final DonationRepository repository;
  
  GetNearbyDonationsUseCase(this.repository);
  
  Future<Either<Failure, List<Donation>>> call(
    double latitude,
    double longitude,
    double radius,
  ) async {
    return await repository.getNearbyDonations(latitude, longitude);
  }
}
```

### 3. Provider Pattern (State Management)

Used for dependency injection and state management.

```dart
class DonorProvider extends ChangeNotifier {
  final CreateDonationUseCase createDonationUseCase;
  
  DonationState _state = DonationInitial();
  
  Future<void> createDonation(Donation donation) async {
    _state = DonationLoading();
    notifyListeners();
    
    final result = await createDonationUseCase(donation);
    
    result.fold(
      (failure) => _state = DonationError(failure.message),
      (donation) => _state = DonationSuccess(donation),
    );
    notifyListeners();
  }
}
```

### 4. Factory Pattern

Used for creating objects based on conditions.

```dart
class UserFactory {
  static UserModel createUser(UserType type, Map<String, dynamic> data) {
    switch (type) {
      case UserType.donor:
        return DonorModel.fromMap(data);
      case UserType.ngo:
        return NGOModel.fromMap(data);
      default:
        throw Exception('Unknown user type');
    }
  }
}
```

---

## State Management

### Strategy: Provider + ChangeNotifier

**Why Provider?**
- Simple and easy to understand
- Good performance for medium-sized apps
- Official Flutter recommendation
- Excellent integration with Flutter widgets
- Easy testing

### State Management Structure

```dart
// State Classes
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Provider
class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthInitial();
  AuthState get state => _state;
  
  final LoginUseCase loginUseCase;
  
  Future<void> login(String email, String password) async {
    _state = AuthLoading();
    notifyListeners();
    
    final result = await loginUseCase(email, password);
    
    result.fold(
      (failure) {
        _state = AuthError(failure.message);
      },
      (user) {
        _state = AuthSuccess(user);
      },
    );
    notifyListeners();
  }
}
```

---

## Navigation

### Strategy: Go Router

**Why Go Router?**
- Declarative routing
- Deep linking support
- Type-safe navigation
- Nested navigation
- URL-based routing (good for web)

### Route Configuration

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/donor/dashboard',
      builder: (context, state) => DonorDashboard(),
    ),
    GoRoute(
      path: '/donation/:id',
      builder: (context, state) {
        final id = state.params['id']!;
        return DonationDetailsPage(donationId: id);
      },
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = // check auth status
    if (!isLoggedIn && state.location != '/login') {
      return '/login';
    }
    return null;
  },
);
```

---

## Dependency Injection

### Manual DI with Provider

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider(create: (_) => FirebaseService()),
        Provider(create: (_) => LocationService()),
        
        // Repositories
        Provider(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: RemoteDataSourceImpl(),
            localDataSource: LocalDataSourceImpl(),
          ),
        ),
        
        // Use Cases
        Provider(
          create: (context) => LoginUseCase(
            context.read<AuthRepository>(),
          ),
        ),
        
        // Providers
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            loginUseCase: context.read<LoginUseCase>(),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## Error Handling

### Either Pattern (using Dartz)

```dart
// Failure classes
abstract class Failure {
  String get message;
}

class ServerFailure extends Failure {
  @override
  String get message => 'Server error occurred';
}

class NetworkFailure extends Failure {
  @override
  String get message => 'No internet connection';
}

// Usage in repository
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    
    final user = await remoteDataSource.login(email, password);
    return Right(user);
  } on ServerException {
    return Left(ServerFailure());
  } catch (e) {
    return Left(UnknownFailure());
  }
}
```

---

## Data Flow

### Complete flow example: Creating a donation

```
1. USER ACTION
   ↓
2. PRESENTATION (Widget calls Provider)
   CreateDonationPage → DonorProvider.createDonation()
   ↓
3. PROVIDER (Calls Use Case)
   DonorProvider → CreateDonationUseCase.call()
   ↓
4. USE CASE (Executes business logic)
   CreateDonationUseCase → Repository.createDonation()
   ↓
5. REPOSITORY (Manages data sources)
   DonationRepository → RemoteDataSource.createDonation()
   ↓
6. DATA SOURCE (Interacts with external service)
   RemoteDataSource → Firebase Firestore
   ↓
7. RESPONSE BACK UP THE CHAIN
   Firebase → DataSource → Repository → UseCase → Provider → Widget
   ↓
8. UI UPDATE
   Provider.notifyListeners() → Widget rebuilds
```

---

## Testing Strategy

### 1. Unit Tests
Test business logic in isolation.

```dart
void main() {
  group('LoginUseCase', () {
    late LoginUseCase useCase;
    late MockAuthRepository mockRepository;
    
    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LoginUseCase(mockRepository);
    });
    
    test('should return User on successful login', () async {
      // Arrange
      when(mockRepository.login(any, any))
          .thenAnswer((_) async => Right(tUser));
      
      // Act
      final result = await useCase('test@test.com', 'password');
      
      // Assert
      expect(result, Right(tUser));
      verify(mockRepository.login('test@test.com', 'password'));
    });
  });
}
```

### 2. Widget Tests
Test UI components.

```dart
void main() {
  testWidgets('LoginPage shows error on invalid credentials', 
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.enterText(find.byKey(Key('email')), 'invalid@test.com');
    await tester.enterText(find.byKey(Key('password')), 'wrong');
    await tester.tap(find.text('Login'));
    await tester.pump();
    
    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
```

### 3. Integration Tests
Test complete user flows.

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('Complete donation flow', (WidgetTester tester) async {
    // Login
    // Navigate to create donation
    // Fill form
    // Submit
    // Verify donation created
  });
}
```

---

## Security Considerations

### 1. Authentication
- Firebase Authentication for user management
- JWT tokens for API authentication
- Secure token storage using Flutter Secure Storage

### 2. Data Security
- Firestore Security Rules to protect data
- Server-side validation
- Input sanitization

### 3. API Security
- HTTPS only
- API key rotation
- Rate limiting

---

## Performance Optimization

### 1. Image Optimization
- Compress images before upload
- Use cached_network_image for caching
- Generate and use thumbnails

### 2. List Optimization
- Pagination for large lists
- Lazy loading
- Use ListView.builder

### 3. State Management
- Minimize rebuilds with Provider.select
- Use const constructors where possible
- Dispose controllers properly

### 4. Firebase Optimization
- Efficient Firestore queries with indexes
- Batch operations for multiple writes
- Offline persistence enabled

---

## Monitoring & Analytics

### 1. Crash Reporting
- Firebase Crashlytics for crash reports
- Custom error logging

### 2. Analytics
- Firebase Analytics for user behavior
- Track key events (donations created, accepted, completed)

### 3. Performance Monitoring
- Firebase Performance Monitoring
- Track network requests
- Monitor app startup time

---

## Build & Deployment

### Development
```bash
flutter run --flavor dev --target lib/main_dev.dart
```

### Staging
```bash
flutter build apk --flavor staging --target lib/main_staging.dart
```

### Production
```bash
flutter build apk --release --flavor production
flutter build ios --release --flavor production
```

---

## Continuous Integration

### GitHub Actions Workflow

```yaml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter build apk
```

---

## Code Quality

### 1. Linting
- Use flutter_lints package
- Custom lint rules in analysis_options.yaml

### 2. Code Reviews
- All code must be reviewed before merge
- Follow Dart style guide
- Write meaningful commit messages

### 3. Documentation
- Document complex logic
- Add dartdoc comments for public APIs
- Keep README updated

---

## Future Enhancements

### Phase 2
- Offline-first architecture
- GraphQL for efficient data fetching
- Advanced caching strategies
- Microservices architecture for backend

### Phase 3
- AI/ML for food quantity estimation
- Real-time location tracking
- WebSocket for real-time updates
- Multi-language support

---

## References

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Provider Documentation](https://pub.dev/packages/provider)

---

**Document Version:** 1.0  
**Last Updated:** October 2025  
**Status:** Active Development
