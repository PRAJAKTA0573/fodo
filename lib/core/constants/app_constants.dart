/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'FODO';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Food Donation Bridge';
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.fodo.app/v1';
  static const String apiStagingUrl = 'https://api-staging.fodo.app/v1';
  static const int apiTimeout = 30; // seconds
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String ngosCollection = 'ngos';
  static const String donationsCollection = 'donations';
  static const String transactionsCollection = 'transactions';
  static const String notificationsCollection = 'notifications';
  static const String ratingsCollection = 'ratings';
  static const String appSettingsCollection = 'app_settings';
  static const String supportTicketsCollection = 'support_tickets';
  
  // Storage Paths
  static const String profilePhotosPath = 'profile_photos';
  static const String foodPhotosPath = 'food_photos';
  static const String documentsPath = 'documents';
  static const String distributionPhotosPath = 'distribution_photos';
  
  // Shared Preferences Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserType = 'user_type';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  
  // Donation Settings
  static const int maxDonationPhotos = 5;
  static const int maxImageSizeMB = 10;
  static const int defaultSearchRadius = 10; // km
  static const int maxSearchRadius = 50; // km
  static const int donationExpiryHours = 48;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Map Settings
  static const double defaultZoom = 14.0;
  static const double maxZoom = 20.0;
  static const double minZoom = 5.0;
  
  // Rating
  static const int minRating = 1;
  static const int maxRating = 5;
  
  // Contact
  static const String supportEmail = 'support@fodo.app';
  static const String supportPhone = '+91-1234567890';
  static const String websiteUrl = 'https://www.fodo.app';
  
  // Social Media
  static const String facebookUrl = 'https://facebook.com/fodoapp';
  static const String twitterUrl = 'https://twitter.com/fodoapp';
  static const String instagramUrl = 'https://instagram.com/fodoapp';
  
  // Privacy & Terms
  static const String privacyPolicyUrl = 'https://www.fodo.app/privacy';
  static const String termsOfServiceUrl = 'https://www.fodo.app/terms';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration normalAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Delays
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration splashDuration = Duration(seconds: 2);
}

/// User Types
enum UserType {
  donor,
  ngo,
  admin;
  
  String get value => name;
  
  static UserType fromString(String value) {
    return UserType.values.firstWhere(
      (type) => type.name == value.toLowerCase(),
      orElse: () => UserType.donor,
    );
  }
}

/// Donation Status
enum DonationStatus {
  created,
  visible,
  accepted,
  inTransit,
  collected,
  distributed,
  completed,
  cancelled,
  expired;
  
  String get value => name;
  
  String get displayName {
    switch (this) {
      case DonationStatus.created:
        return 'Created';
      case DonationStatus.visible:
        return 'Available';
      case DonationStatus.accepted:
        return 'Accepted';
      case DonationStatus.inTransit:
        return 'On the Way';
      case DonationStatus.collected:
        return 'Collected';
      case DonationStatus.distributed:
        return 'Distributed';
      case DonationStatus.completed:
        return 'Completed';
      case DonationStatus.cancelled:
        return 'Cancelled';
      case DonationStatus.expired:
        return 'Expired';
    }
  }
  
  static DonationStatus fromString(String value) {
    return DonationStatus.values.firstWhere(
      (status) => status.name == value.toLowerCase(),
      orElse: () => DonationStatus.created,
    );
  }
}

/// Food Types
enum FoodType {
  cookedFood,
  packagedFood,
  fruitsVegetables,
  bakery,
  dairy,
  other;
  
  String get value => name;
  
  String get displayName {
    switch (this) {
      case FoodType.cookedFood:
        return 'Cooked Food';
      case FoodType.packagedFood:
        return 'Packaged Food';
      case FoodType.fruitsVegetables:
        return 'Fruits & Vegetables';
      case FoodType.bakery:
        return 'Bakery Items';
      case FoodType.dairy:
        return 'Dairy Products';
      case FoodType.other:
        return 'Other';
    }
  }
  
  static FoodType fromString(String value) {
    return FoodType.values.firstWhere(
      (type) => type.name == value.toLowerCase().replaceAll('_', ''),
      orElse: () => FoodType.other,
    );
  }
}

/// Quantity Units
enum QuantityUnit {
  people,
  kg,
  plates,
  packets;
  
  String get value => name;
  
  String get displayName {
    switch (this) {
      case QuantityUnit.people:
        return 'People';
      case QuantityUnit.kg:
        return 'Kilograms';
      case QuantityUnit.plates:
        return 'Plates';
      case QuantityUnit.packets:
        return 'Packets';
    }
  }
}

/// NGO Verification Status
enum VerificationStatus {
  pending,
  verified,
  rejected;
  
  String get value => name;
  
  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }
}

/// Notification Types
enum NotificationType {
  donationCreated,
  donationAccepted,
  pickupStarted,
  pickupCompleted,
  distributionCompleted,
  ratingRequest,
  verificationStatus,
  systemAnnouncement;
  
  String get value => name;
}
