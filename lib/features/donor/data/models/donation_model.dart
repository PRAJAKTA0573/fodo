import 'package:firebase_database/firebase_database.dart';
import '../../../../core/constants/app_constants.dart';

/// Donation Model - Complete donation information
class DonationModel {
  final String donationId;
  final String donorId;
  final DonorInfo donorInfo;
  final FoodDetails foodDetails;
  final PickupLocation pickupLocation;
  final DonationStatus status;
  final String? acceptedByNgoId;
  final NgoInfo? ngoInfo;
  final Timeline timeline;
  final String? specialInstructions;
  final String? cancellationReason;
  final Rating? rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  DonationModel({
    required this.donationId,
    required this.donorId,
    required this.donorInfo,
    required this.foodDetails,
    required this.pickupLocation,
    required this.status,
    this.acceptedByNgoId,
    this.ngoInfo,
    required this.timeline,
    this.specialInstructions,
    this.cancellationReason,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  /// Create from Firebase Realtime Database
  factory DonationModel.fromDatabase(Map<String, dynamic> data, String donationId) {
    return DonationModel(
      donationId: donationId,
      donorId: data['donorId'] ?? '',
      donorInfo: DonorInfo.fromMap(data['donorInfo'] ?? {}),
      foodDetails: FoodDetails.fromMap(data['foodDetails'] ?? {}),
      pickupLocation: PickupLocation.fromMap(data['pickupLocation'] ?? {}),
      status: DonationStatus.fromString(data['status'] ?? 'created'),
      acceptedByNgoId: data['acceptedByNgoId'],
      ngoInfo: data['ngoInfo'] != null ? NgoInfo.fromMap(data['ngoInfo']) : null,
      timeline: Timeline.fromMap(data['timeline'] ?? {}),
      specialInstructions: data['specialInstructions'],
      cancellationReason: data['cancellationReason'],
      rating: data['rating'] != null ? Rating.fromMap(data['rating']) : null,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int)
          : DateTime.now(),
      expiresAt: data['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['expiresAt'] as int)
          : null,
    );
  }

  /// Convert to Firebase Realtime Database
  Map<String, dynamic> toDatabase() {
    return {
      'donorId': donorId,
      'donorInfo': donorInfo.toMap(),
      'foodDetails': foodDetails.toMap(),
      'pickupLocation': pickupLocation.toMap(),
      'status': status.value,
      'acceptedByNgoId': acceptedByNgoId,
      'ngoInfo': ngoInfo?.toMap(),
      'timeline': timeline.toMap(),
      'specialInstructions': specialInstructions,
      'cancellationReason': cancellationReason,
      'rating': rating?.toMap(),
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
      'expiresAt': expiresAt?.millisecondsSinceEpoch,
    };
  }

  DonationModel copyWith({
    String? donationId,
    String? donorId,
    DonorInfo? donorInfo,
    FoodDetails? foodDetails,
    PickupLocation? pickupLocation,
    DonationStatus? status,
    String? acceptedByNgoId,
    NgoInfo? ngoInfo,
    Timeline? timeline,
    String? specialInstructions,
    String? cancellationReason,
    Rating? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return DonationModel(
      donationId: donationId ?? this.donationId,
      donorId: donorId ?? this.donorId,
      donorInfo: donorInfo ?? this.donorInfo,
      foodDetails: foodDetails ?? this.foodDetails,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      status: status ?? this.status,
      acceptedByNgoId: acceptedByNgoId ?? this.acceptedByNgoId,
      ngoInfo: ngoInfo ?? this.ngoInfo,
      timeline: timeline ?? this.timeline,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// Donor Information (embedded in donation)
class DonorInfo {
  final String name;
  final String phone;
  final String? alternatePhone;
  final String? organizationName;

  DonorInfo({
    required this.name,
    required this.phone,
    this.alternatePhone,
    this.organizationName,
  });

  factory DonorInfo.fromMap(Map<String, dynamic> map) {
    return DonorInfo(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      alternatePhone: map['alternatePhone'],
      organizationName: map['organizationName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'alternatePhone': alternatePhone,
      'organizationName': organizationName,
    };
  }
}

/// Food Details
class FoodDetails {
  final FoodType foodType;
  final String description;
  final Quantity quantity;
  final int estimatedPeopleFed;
  final List<PhotoInfo> photos;
  final DateTime bestBefore;
  final bool isVegetarian;
  final bool isPackaged;
  final List<String> allergens;

  FoodDetails({
    required this.foodType,
    required this.description,
    required this.quantity,
    required this.estimatedPeopleFed,
    this.photos = const [],
    required this.bestBefore,
    this.isVegetarian = true,
    this.isPackaged = false,
    this.allergens = const [],
  });

  factory FoodDetails.fromMap(Map<String, dynamic> map) {
    return FoodDetails(
      foodType: FoodType.fromString(map['foodType'] ?? 'other'),
      description: map['description'] ?? '',
      quantity: Quantity.fromMap(map['quantity'] ?? {}),
      estimatedPeopleFed: map['estimatedPeopleFed'] ?? 0,
      photos: (map['photos'] as List<dynamic>?)
              ?.map((p) => PhotoInfo.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      bestBefore: map['bestBefore'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['bestBefore'] as int)
          : DateTime.now().add(const Duration(hours: 4)),
      isVegetarian: map['isVegetarian'] ?? true,
      isPackaged: map['isPackaged'] ?? false,
      allergens: List<String>.from(map['allergens'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodType': foodType.value,
      'description': description,
      'quantity': quantity.toMap(),
      'estimatedPeopleFed': estimatedPeopleFed,
      'photos': photos.map((p) => p.toMap()).toList(),
      'bestBefore': bestBefore.millisecondsSinceEpoch,
      'isVegetarian': isVegetarian,
      'isPackaged': isPackaged,
      'allergens': allergens,
    };
  }
}

/// Quantity Information
class Quantity {
  final double value;
  final QuantityUnit unit;

  Quantity({
    required this.value,
    required this.unit,
  });

  factory Quantity.fromMap(Map<String, dynamic> map) {
    return Quantity(
      value: (map['value'] ?? 0).toDouble(),
      unit: QuantityUnit.values.firstWhere(
        (u) => u.value == map['unit'],
        orElse: () => QuantityUnit.people,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'unit': unit.value,
    };
  }
}

/// Photo Information
class PhotoInfo {
  final String url;
  final String thumbnailUrl;
  final DateTime uploadedAt;
  final int fileSize;

  PhotoInfo({
    required this.url,
    required this.thumbnailUrl,
    required this.uploadedAt,
    required this.fileSize,
  });

  factory PhotoInfo.fromMap(Map<String, dynamic> map) {
    return PhotoInfo(
      url: map['url'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['uploadedAt'] as int)
          : DateTime.now(),
      fileSize: map['fileSize'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
      'fileSize': fileSize,
    };
  }
}

/// Pickup Location
class PickupLocation {
  final String fullAddress;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? landmark;
  final String? instructions;

  PickupLocation({
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.landmark,
    this.instructions,
  });

  factory PickupLocation.fromMap(Map<String, dynamic> map) {
    return PickupLocation(
      fullAddress: map['fullAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      landmark: map['landmark'],
      instructions: map['instructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullAddress': fullAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
      'instructions': instructions,
    };
  }
}

/// NGO Information (when accepted)
class NgoInfo {
  final String ngoId;
  final String ngoName;
  final String contactPerson;
  final String contactPhone;
  final DateTime? estimatedPickupTime;

  NgoInfo({
    required this.ngoId,
    required this.ngoName,
    required this.contactPerson,
    required this.contactPhone,
    this.estimatedPickupTime,
  });

  factory NgoInfo.fromMap(Map<String, dynamic> map) {
    return NgoInfo(
      ngoId: map['ngoId'] ?? '',
      ngoName: map['ngoName'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      estimatedPickupTime: map['estimatedPickupTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['estimatedPickupTime'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ngoId': ngoId,
      'ngoName': ngoName,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'estimatedPickupTime': estimatedPickupTime?.millisecondsSinceEpoch,
    };
  }
}

/// Timeline of donation events
class Timeline {
  final DateTime createdAt;
  final DateTime? visibleAt;
  final DateTime? acceptedAt;
  final DateTime? inTransitAt;
  final DateTime? collectedAt;
  final DateTime? distributedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  Timeline({
    required this.createdAt,
    this.visibleAt,
    this.acceptedAt,
    this.inTransitAt,
    this.collectedAt,
    this.distributedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory Timeline.fromMap(Map<String, dynamic> map) {
    return Timeline(
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      visibleAt: map['visibleAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['visibleAt'] as int)
          : null,
      acceptedAt: map['acceptedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['acceptedAt'] as int)
          : null,
      inTransitAt: map['inTransitAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['inTransitAt'] as int)
          : null,
      collectedAt: map['collectedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['collectedAt'] as int)
          : null,
      distributedAt: map['distributedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['distributedAt'] as int)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['cancelledAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': createdAt.millisecondsSinceEpoch,
      'visibleAt': visibleAt?.millisecondsSinceEpoch,
      'acceptedAt': acceptedAt?.millisecondsSinceEpoch,
      'inTransitAt': inTransitAt?.millisecondsSinceEpoch,
      'collectedAt': collectedAt?.millisecondsSinceEpoch,
      'distributedAt': distributedAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
    };
  }
}

/// Rating given by donor to NGO
class Rating {
  final double rating;
  final String? comment;
  final DateTime ratedAt;

  Rating({
    required this.rating,
    this.comment,
    required this.ratedAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'],
      ratedAt: map['ratedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['ratedAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
      'ratedAt': ratedAt.millisecondsSinceEpoch,
    };
  }
}
