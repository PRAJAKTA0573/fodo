import 'package:firebase_database/firebase_database.dart';

/// NGO Model - Complete NGO information
class NGOModel {
  final String ngoId;
  final String ngoName;
  final String registrationNumber;
  final String registrationType;
  final NGOContactPerson contactPerson;
  final NGOLocation location;
  final List<String> serviceAreas;
  final NGOVerification verification;
  final NGOOperatingHours operatingHours;
  final NGOStatistics statistics;
  final List<String> documents;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  NGOModel({
    required this.ngoId,
    required this.ngoName,
    required this.registrationNumber,
    required this.registrationType,
    required this.contactPerson,
    required this.location,
    required this.serviceAreas,
    required this.verification,
    required this.operatingHours,
    required this.statistics,
    this.documents = const [],
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  factory NGOModel.fromDatabase(Map<String, dynamic> data, String ngoId) {
    return NGOModel(
      ngoId: ngoId,
      ngoName: data['ngoName'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      registrationType: data['registrationType'] ?? '',
      contactPerson: NGOContactPerson.fromMap(data['contactPerson'] ?? {}),
      location: NGOLocation.fromMap(data['location'] ?? {}),
      serviceAreas: List<String>.from(data['serviceAreas'] ?? []),
      verification: NGOVerification.fromMap(data['verification'] ?? {}),
      operatingHours: NGOOperatingHours.fromMap(data['operatingHours'] ?? {}),
      statistics: NGOStatistics.fromMap(data['statistics'] ?? {}),
      documents: List<String>.from(data['documents'] ?? []),
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'ngoName': ngoName,
      'registrationNumber': registrationNumber,
      'registrationType': registrationType,
      'contactPerson': contactPerson.toMap(),
      'location': location.toMap(),
      'serviceAreas': serviceAreas,
      'verification': verification.toMap(),
      'operatingHours': operatingHours.toMap(),
      'statistics': statistics.toMap(),
      'documents': documents,
      'status': status,
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    };
  }

  NGOModel copyWith({
    String? ngoName,
    String? registrationNumber,
    String? registrationType,
    NGOContactPerson? contactPerson,
    NGOLocation? location,
    List<String>? serviceAreas,
    NGOVerification? verification,
    NGOOperatingHours? operatingHours,
    NGOStatistics? statistics,
    List<String>? documents,
    String? status,
  }) {
    return NGOModel(
      ngoId: ngoId,
      ngoName: ngoName ?? this.ngoName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registrationType: registrationType ?? this.registrationType,
      contactPerson: contactPerson ?? this.contactPerson,
      location: location ?? this.location,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      verification: verification ?? this.verification,
      operatingHours: operatingHours ?? this.operatingHours,
      statistics: statistics ?? this.statistics,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// NGO Contact Person
class NGOContactPerson {
  final String name;
  final String designation;
  final String phone;
  final String email;
  final String? alternatePhone;

  NGOContactPerson({
    required this.name,
    required this.designation,
    required this.phone,
    required this.email,
    this.alternatePhone,
  });

  factory NGOContactPerson.fromMap(Map<String, dynamic> map) {
    return NGOContactPerson(
      name: map['name'] ?? '',
      designation: map['designation'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      alternatePhone: map['alternatePhone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'designation': designation,
      'phone': phone,
      'email': email,
      'alternatePhone': alternatePhone,
    };
  }
}

/// NGO Location
class NGOLocation {
  final String address;
  final String city;
  final String state;
  final String pincode;
  final NGOCoordinates coordinates;

  NGOLocation({
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.coordinates,
  });

  factory NGOLocation.fromMap(Map<String, dynamic> map) {
    return NGOLocation(
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      coordinates: NGOCoordinates.fromMap(map['coordinates'] ?? {}),
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

/// NGO Coordinates
class NGOCoordinates {
  final double latitude;
  final double longitude;

  NGOCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory NGOCoordinates.fromMap(Map<String, dynamic> map) {
    return NGOCoordinates(
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

/// NGO Verification Status
class NGOVerification {
  final String status; // 'pending', 'verified', 'rejected'
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final String? rejectionReason;

  NGOVerification({
    this.status = 'pending',
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
  });

  factory NGOVerification.fromMap(Map<String, dynamic> map) {
    return NGOVerification(
      status: map['status'] ?? 'pending',
      verifiedAt: map['verifiedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['verifiedAt'] as int)
          : null,
      verifiedBy: map['verifiedBy'],
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'verifiedAt': verifiedAt?.millisecondsSinceEpoch,
      'verifiedBy': verifiedBy,
      'rejectionReason': rejectionReason,
    };
  }
}

/// NGO Operating Hours
class NGOOperatingHours {
  final String startTime;
  final String endTime;
  final List<String> workingDays;
  final bool available24x7;

  NGOOperatingHours({
    this.startTime = '09:00',
    this.endTime = '18:00',
    this.workingDays = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    this.available24x7 = false,
  });

  factory NGOOperatingHours.fromMap(Map<String, dynamic> map) {
    return NGOOperatingHours(
      startTime: map['startTime'] ?? '09:00',
      endTime: map['endTime'] ?? '18:00',
      workingDays: List<String>.from(map['workingDays'] ?? []),
      available24x7: map['available24x7'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'workingDays': workingDays,
      'available24x7': available24x7,
    };
  }
}

/// NGO Statistics
class NGOStatistics {
  final int totalCollections;
  final int totalPeopleFed;
  final double totalFoodWeight;
  final int completedCollections;
  final int cancelledCollections;
  final double averageResponseTime;
  final double rating;
  final int totalRatings;

  NGOStatistics({
    this.totalCollections = 0,
    this.totalPeopleFed = 0,
    this.totalFoodWeight = 0.0,
    this.completedCollections = 0,
    this.cancelledCollections = 0,
    this.averageResponseTime = 0.0,
    this.rating = 0.0,
    this.totalRatings = 0,
  });

  factory NGOStatistics.fromMap(Map<String, dynamic> map) {
    return NGOStatistics(
      totalCollections: map['totalCollections'] ?? 0,
      totalPeopleFed: map['totalPeopleFed'] ?? 0,
      totalFoodWeight: (map['totalFoodWeight'] ?? 0.0).toDouble(),
      completedCollections: map['completedCollections'] ?? 0,
      cancelledCollections: map['cancelledCollections'] ?? 0,
      averageResponseTime: (map['averageResponseTime'] ?? 0.0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalCollections': totalCollections,
      'totalPeopleFed': totalPeopleFed,
      'totalFoodWeight': totalFoodWeight,
      'completedCollections': completedCollections,
      'cancelledCollections': cancelledCollections,
      'averageResponseTime': averageResponseTime,
      'rating': rating,
      'totalRatings': totalRatings,
    };
  }

  NGOStatistics copyWith({
    int? totalCollections,
    int? totalPeopleFed,
    double? totalFoodWeight,
    int? completedCollections,
    int? cancelledCollections,
    double? averageResponseTime,
    double? rating,
    int? totalRatings,
  }) {
    return NGOStatistics(
      totalCollections: totalCollections ?? this.totalCollections,
      totalPeopleFed: totalPeopleFed ?? this.totalPeopleFed,
      totalFoodWeight: totalFoodWeight ?? this.totalFoodWeight,
      completedCollections: completedCollections ?? this.completedCollections,
      cancelledCollections: cancelledCollections ?? this.cancelledCollections,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
    );
  }
}
