import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';

/// User Model
class UserModel {
  final String userId;
  final UserType userType;
  final String email;
  final String phoneNumber;
  final bool phoneVerified;
  final bool emailVerified;
  final ProfileData profileData;
  final Location location;
  final List<String> fcmTokens;
  final NotificationPreferences notificationPreferences;
  final UserStatistics statistics;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.userId,
    required this.userType,
    required this.email,
    required this.phoneNumber,
    this.phoneVerified = false,
    this.emailVerified = false,
    required this.profileData,
    required this.location,
    this.fcmTokens = const [],
    required this.notificationPreferences,
    required this.statistics,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  /// Convert from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  UserModel copyWith({
    String? userId,
    UserType? userType,
    String? email,
    String? phoneNumber,
    bool? phoneVerified,
    bool? emailVerified,
    ProfileData? profileData,
    Location? location,
    List<String>? fcmTokens,
    NotificationPreferences? notificationPreferences,
    UserStatistics? statistics,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      emailVerified: emailVerified ?? this.emailVerified,
      profileData: profileData ?? this.profileData,
      location: location ?? this.location,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      statistics: statistics ?? this.statistics,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// Profile Data
class ProfileData {
  final String fullName;
  final String? photoUrl;
  final String? organizationName;
  final String? bio;

  ProfileData({
    required this.fullName,
    this.photoUrl,
    this.organizationName,
    this.bio,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      fullName: map['fullName'] ?? '',
      photoUrl: map['photoUrl'],
      organizationName: map['organizationName'],
      bio: map['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'photoUrl': photoUrl,
      'organizationName': organizationName,
      'bio': bio,
    };
  }
}

/// Location
class Location {
  final String address;
  final String city;
  final String state;
  final String pincode;
  final Coordinates coordinates;

  Location({
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.coordinates,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      coordinates: Coordinates.fromMap(map['coordinates'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'coordinates': coordinates.toMap(),
    };
  }
}

/// Coordinates
class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Notification Preferences
class NotificationPreferences {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  NotificationPreferences({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      pushEnabled: map['pushEnabled'] ?? true,
      emailEnabled: map['emailEnabled'] ?? true,
      smsEnabled: map['smsEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
    };
  }
}

/// User Statistics
class UserStatistics {
  final int totalDonations;
  final int totalPeopleFed;
  final double impactScore;

  UserStatistics({
    this.totalDonations = 0,
    this.totalPeopleFed = 0,
    this.impactScore = 0.0,
  });

  factory UserStatistics.fromMap(Map<String, dynamic> map) {
    return UserStatistics(
      totalDonations: map['totalDonations'] ?? 0,
      totalPeopleFed: map['totalPeopleFed'] ?? 0,
      impactScore: (map['impactScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalDonations': totalDonations,
      'totalPeopleFed': totalPeopleFed,
      'impactScore': impactScore,
    };
  }
}
