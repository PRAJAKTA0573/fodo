# FODO - Database Schema Design

## Overview

This document defines the complete database schema for the FODO application using Firebase Firestore as the primary database.

## Database Type: Firebase Firestore (NoSQL)

Firestore is a flexible, scalable NoSQL cloud database that stores data in documents organized into collections.

---

## Collections Structure

```
firestore/
├── users/
├── donations/
├── ngos/
├── transactions/
├── notifications/
├── ratings/
├── app_settings/
└── support_tickets/
```

---

## 1. Users Collection

**Collection Name:** `users`

Stores information about all users (both donors and NGOs).

### Document Structure

```json
{
  "userId": "string (auto-generated)",
  "userType": "string (enum: 'donor', 'ngo', 'admin')",
  "email": "string",
  "phoneNumber": "string",
  "phoneVerified": "boolean",
  "emailVerified": "boolean",
  "profileData": {
    "fullName": "string",
    "photoUrl": "string (optional)",
    "organizationName": "string (optional - for caterers/restaurants)",
    "bio": "string (optional)"
  },
  "location": {
    "address": "string",
    "city": "string",
    "state": "string",
    "pincode": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  "fcmTokens": ["array of strings (for push notifications)"],
  "notificationPreferences": {
    "pushEnabled": "boolean",
    "emailEnabled": "boolean",
    "smsEnabled": "boolean"
  },
  "statistics": {
    "totalDonations": "number",
    "totalPeopleFed": "number",
    "impactScore": "number"
  },
  "status": "string (enum: 'active', 'suspended', 'deleted')",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "lastLoginAt": "timestamp"
}
```

### Indexes
- `email` (unique)
- `phoneNumber` (unique)
- `userType`
- `status`
- `location.coordinates` (geohash for proximity queries)

---

## 2. NGOs Collection

**Collection Name:** `ngos`

Stores detailed information about NGO organizations (extends user data).

### Document Structure

```json
{
  "ngoId": "string (same as userId)",
  "ngoName": "string",
  "registrationNumber": "string",
  "registrationType": "string (enum: 'Trust', 'Society', '80G', '12A', 'Section 8 Company')",
  "contactPerson": {
    "name": "string",
    "designation": "string",
    "phone": "string",
    "email": "string"
  },
  "operatingDetails": {
    "foundedYear": "number",
    "numberOfVolunteers": "number",
    "serviceAreas": ["array of strings - city/district names"],
    "operatingHours": {
      "monday": {"open": "string", "close": "string"},
      "tuesday": {"open": "string", "close": "string"},
      // ... other days
      "availability": "string (24/7, business hours, custom)"
    }
  },
  "verification": {
    "status": "string (enum: 'pending', 'verified', 'rejected')",
    "submittedAt": "timestamp",
    "verifiedAt": "timestamp",
    "verifiedBy": "string (admin userId)",
    "rejectionReason": "string (if rejected)",
    "documents": [
      {
        "type": "string (registration_certificate, 80g_certificate, etc.)",
        "url": "string",
        "uploadedAt": "timestamp"
      }
    ]
  },
  "serviceCapacity": {
    "vehicleAvailable": "boolean",
    "storageCapacity": "string",
    "teamSize": "number",
    "maxPickupRadius": "number (in km)"
  },
  "statistics": {
    "totalCollections": "number",
    "totalPeopleFed": "number",
    "totalFoodCollected": "number (in kg)",
    "averageResponseTime": "number (in minutes)",
    "successRate": "number (percentage)",
    "rating": "number (average rating out of 5)"
  },
  "bankDetails": {
    "accountName": "string",
    "accountNumber": "string (encrypted)",
    "ifscCode": "string",
    "upiId": "string (optional)"
  },
  "socialMedia": {
    "website": "string (optional)",
    "facebook": "string (optional)",
    "twitter": "string (optional)",
    "instagram": "string (optional)"
  },
  "status": "string (enum: 'active', 'inactive', 'suspended')",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Indexes
- `registrationNumber` (unique)
- `verification.status`
- `operatingDetails.serviceAreas` (array-contains)
- `status`

---

## 3. Donations Collection

**Collection Name:** `donations`

Stores all donation requests created by donors.

### Document Structure

```json
{
  "donationId": "string (auto-generated)",
  "donorId": "string (reference to users collection)",
  "donorInfo": {
    "name": "string",
    "phone": "string",
    "alternatePhone": "string (optional)",
    "organizationName": "string (optional)"
  },
  "foodDetails": {
    "foodType": "string (enum: 'cooked_food', 'packaged_food', 'fruits_vegetables', 'bakery', 'dairy', 'other')",
    "description": "string",
    "quantity": {
      "value": "number",
      "unit": "string (people, kg, plates, packets)"
    },
    "estimatedPeopleFed": "number",
    "photos": [
      {
        "url": "string",
        "thumbnail": "string",
        "uploadedAt": "timestamp"
      }
    ],
    "dietaryInfo": {
      "isVegetarian": "boolean",
      "isVegan": "boolean",
      "containsNuts": "boolean",
      "containsDairy": "boolean",
      "isHalal": "boolean",
      "isKosher": "boolean"
    }
  },
  "pickupDetails": {
    "address": {
      "fullAddress": "string",
      "landmark": "string",
      "city": "string",
      "state": "string",
      "pincode": "string",
      "coordinates": {
        "latitude": "number",
        "longitude": "number"
      }
    },
    "availableFrom": "timestamp",
    "availableUntil": "timestamp",
    "preferredPickupTime": "string (optional)",
    "specialInstructions": "string (optional)"
  },
  "status": "string (enum: 'created', 'visible', 'accepted', 'in_transit', 'collected', 'distributed', 'completed', 'cancelled', 'expired')",
  "statusHistory": [
    {
      "status": "string",
      "timestamp": "timestamp",
      "updatedBy": "string (userId)",
      "notes": "string (optional)"
    }
  ],
  "ngoInfo": {
    "ngoId": "string (null if not accepted yet)",
    "ngoName": "string",
    "acceptedAt": "timestamp",
    "collectedAt": "timestamp",
    "distributedAt": "timestamp",
    "completedAt": "timestamp"
  },
  "tracking": {
    "viewCount": "number",
    "acceptedBy": "array of ngoIds who tried to accept",
    "estimatedArrivalTime": "timestamp (optional)",
    "actualCollectionTime": "timestamp (optional)"
  },
  "impact": {
    "peopleFed": "number (actual, filled by NGO)",
    "distributionLocation": "string (optional)",
    "distributionPhotos": ["array of photo URLs"]
  },
  "flags": {
    "isUrgent": "boolean",
    "isRecurring": "boolean",
    "needsContainers": "boolean",
    "isRefrigerated": "boolean"
  },
  "cancellation": {
    "cancelledBy": "string (userId)",
    "reason": "string",
    "cancelledAt": "timestamp"
  },
  "metadata": {
    "source": "string (mobile_app, web_app)",
    "appVersion": "string"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "expiresAt": "timestamp"
}
```

### Indexes
- `donorId`
- `status`
- `ngoInfo.ngoId`
- `pickupDetails.address.coordinates` (geohash)
- `pickupDetails.availableFrom`
- `createdAt`
- Composite: `status + pickupDetails.address.city`
- Composite: `status + foodDetails.foodType`

---

## 4. Transactions Collection

**Collection Name:** `transactions`

Records the complete transaction history between donors and NGOs.

### Document Structure

```json
{
  "transactionId": "string (auto-generated)",
  "donationId": "string (reference to donations)",
  "donorId": "string (reference to users)",
  "ngoId": "string (reference to ngos)",
  "timeline": {
    "requestCreated": "timestamp",
    "requestAccepted": "timestamp",
    "pickupStarted": "timestamp",
    "pickupCompleted": "timestamp",
    "distributionCompleted": "timestamp",
    "transactionClosed": "timestamp"
  },
  "foodDetails": {
    "foodType": "string",
    "quantity": "number",
    "estimatedPeople": "number",
    "actualPeopleFed": "number"
  },
  "location": {
    "pickupAddress": "string",
    "pickupCoordinates": {
      "latitude": "number",
      "longitude": "number"
    },
    "distributionLocation": "string (optional)"
  },
  "status": "string (enum: 'completed', 'failed', 'cancelled')",
  "failureReason": "string (if failed)",
  "rating": {
    "donorRating": {
      "score": "number (1-5)",
      "review": "string",
      "ratedAt": "timestamp"
    },
    "ngoRating": {
      "score": "number (1-5)",
      "review": "string",
      "ratedAt": "timestamp"
    }
  },
  "impact": {
    "peopleFed": "number",
    "foodSaved": "number (in kg)",
    "co2Saved": "number (estimated)"
  },
  "createdAt": "timestamp",
  "completedAt": "timestamp"
}
```

### Indexes
- `donorId`
- `ngoId`
- `donationId`
- `status`
- `createdAt`
- Composite: `ngoId + createdAt`
- Composite: `donorId + createdAt`

---

## 5. Notifications Collection

**Collection Name:** `notifications`

Stores all notifications sent to users.

### Document Structure

```json
{
  "notificationId": "string (auto-generated)",
  "userId": "string (recipient)",
  "type": "string (enum: 'donation_created', 'donation_accepted', 'pickup_started', 'pickup_completed', 'distribution_completed', 'rating_request', 'verification_status', 'system_announcement')",
  "title": "string",
  "body": "string",
  "data": {
    "donationId": "string (optional)",
    "ngoId": "string (optional)",
    "transactionId": "string (optional)",
    "actionUrl": "string (deep link)"
  },
  "priority": "string (enum: 'high', 'normal', 'low')",
  "status": "string (enum: 'sent', 'delivered', 'read', 'failed')",
  "channels": {
    "push": {
      "sent": "boolean",
      "sentAt": "timestamp",
      "delivered": "boolean",
      "deliveredAt": "timestamp"
    },
    "email": {
      "sent": "boolean",
      "sentAt": "timestamp",
      "opened": "boolean",
      "openedAt": "timestamp"
    },
    "sms": {
      "sent": "boolean",
      "sentAt": "timestamp"
    }
  },
  "readAt": "timestamp (null if unread)",
  "createdAt": "timestamp",
  "expiresAt": "timestamp"
}
```

### Indexes
- `userId`
- `status`
- `type`
- `createdAt`
- Composite: `userId + status`
- Composite: `userId + createdAt`

---

## 6. Ratings Collection

**Collection Name:** `ratings`

Stores ratings and reviews given by donors and NGOs.

### Document Structure

```json
{
  "ratingId": "string (auto-generated)",
  "transactionId": "string (reference)",
  "donationId": "string (reference)",
  "ratedBy": {
    "userId": "string",
    "userType": "string (donor or ngo)"
  },
  "ratedTo": {
    "userId": "string",
    "userType": "string (donor or ngo)"
  },
  "rating": {
    "score": "number (1-5)",
    "review": "string (optional)",
    "categories": {
      "communication": "number (1-5)",
      "timeliness": "number (1-5)",
      "foodQuality": "number (1-5) - for donor ratings",
      "professionalism": "number (1-5) - for NGO ratings"
    }
  },
  "flags": {
    "isEdited": "boolean",
    "editedAt": "timestamp",
    "isReported": "boolean",
    "reportReason": "string"
  },
  "response": {
    "text": "string (optional - reply from rated party)",
    "respondedAt": "timestamp"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Indexes
- `ratedTo.userId`
- `ratedBy.userId`
- `transactionId`
- `createdAt`

---

## 7. App Settings Collection

**Collection Name:** `app_settings`

Stores global application settings and configurations.

### Document Structure

```json
{
  "settingId": "string",
  "category": "string (enum: 'general', 'notifications', 'limits', 'features')",
  "key": "string",
  "value": "any",
  "description": "string",
  "updatedBy": "string (admin userId)",
  "updatedAt": "timestamp"
}
```

### Example Settings:
```json
{
  "settingId": "max_donation_radius",
  "category": "limits",
  "key": "max_radius_km",
  "value": 50,
  "description": "Maximum radius for NGO search"
}
```

---

## 8. Support Tickets Collection

**Collection Name:** `support_tickets`

Stores user-reported issues and support requests.

### Document Structure

```json
{
  "ticketId": "string (auto-generated)",
  "userId": "string",
  "userType": "string",
  "category": "string (enum: 'bug', 'feature_request', 'account_issue', 'donation_issue', 'other')",
  "subject": "string",
  "description": "string",
  "attachments": ["array of URLs"],
  "priority": "string (enum: 'low', 'medium', 'high', 'critical')",
  "status": "string (enum: 'open', 'in_progress', 'resolved', 'closed')",
  "assignedTo": "string (admin userId)",
  "messages": [
    {
      "from": "string (userId)",
      "message": "string",
      "timestamp": "timestamp"
    }
  ],
  "resolvedAt": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

## Security Rules

### Firestore Security Rules (firestore.rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isNGO() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType == 'ngo';
    }
    
    function isDonor() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType == 'donor';
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType == 'admin';
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
    }
    
    // NGOs collection
    match /ngos/{ngoId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(ngoId) && isNGO();
      allow update: if isOwner(ngoId) || isAdmin();
      allow delete: if isAdmin();
    }
    
    // Donations collection
    match /donations/{donationId} {
      allow read: if isAuthenticated();
      allow create: if isDonor();
      allow update: if (isDonor() && resource.data.donorId == request.auth.uid) ||
                       (isNGO() && resource.data.ngoInfo.ngoId == request.auth.uid) ||
                       isAdmin();
      allow delete: if resource.data.donorId == request.auth.uid || isAdmin();
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      allow read: if isAuthenticated() && 
                     (resource.data.donorId == request.auth.uid || 
                      resource.data.ngoId == request.auth.uid ||
                      isAdmin());
      allow create: if isAuthenticated();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create: if isAdmin();
      allow update: if resource.data.userId == request.auth.uid;
      allow delete: if resource.data.userId == request.auth.uid || isAdmin();
    }
    
    // Ratings collection
    match /ratings/{ratingId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.resource.data.ratedBy.userId == request.auth.uid;
      allow update: if resource.data.ratedBy.userId == request.auth.uid;
      allow delete: if isAdmin();
    }
    
    // App Settings
    match /app_settings/{settingId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
    
    // Support Tickets
    match /support_tickets/{ticketId} {
      allow read: if isAuthenticated() && 
                     (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isAuthenticated();
      allow update: if isAdmin() || resource.data.userId == request.auth.uid;
      allow delete: if isAdmin();
    }
  }
}
```

---

## Data Relationships

```
User (Donor) ──┬── Creates ──> Donation
                │
                └── Rates ──> NGO
                │
                └── Has ──> Notifications
                │
                └── Creates ──> Support Tickets

NGO ──┬── Accepts ──> Donation
      │
      └── Completes ──> Transaction
      │
      └── Receives ──> Rating
      │
      └── Has ──> Notifications

Donation ──┬── Belongs to ──> Transaction
           │
           └── Has ──> Tracking Info
           │
           └── Generates ──> Notifications

Transaction ──> Has ──> Ratings (bidirectional)
```

---

## Query Patterns & Optimization

### Common Queries

1. **Find nearby donations for NGO**
```javascript
donations
  .where('status', '==', 'visible')
  .where('location.coordinates', 'near', ngoLocation)
  .orderBy('createdAt', 'desc')
```

2. **Get donor's donation history**
```javascript
donations
  .where('donorId', '==', userId)
  .orderBy('createdAt', 'desc')
  .limit(20)
```

3. **Get NGO's collections**
```javascript
donations
  .where('ngoInfo.ngoId', '==', ngoId)
  .where('status', 'in', ['accepted', 'in_transit', 'collected'])
  .orderBy('createdAt', 'desc')
```

4. **Get unread notifications**
```javascript
notifications
  .where('userId', '==', userId)
  .where('status', '==', 'delivered')
  .where('readAt', '==', null)
  .orderBy('createdAt', 'desc')
```

---

## Backup & Data Retention

### Backup Strategy
- **Daily automated backups** using Firebase scheduled exports
- **Retention period**: 90 days for active data
- **Archive period**: 2 years for completed transactions
- **Permanent deletion**: After 2 years (except for analytics)

### Data Cleanup Rules
- Expired donations (auto-delete after 7 days)
- Read notifications (delete after 30 days)
- Completed transactions (archive after 90 days)
- Cancelled donations (archive after 30 days)

---

## Migration Plan

### Phase 1: Initial Setup
1. Create collections with sample data
2. Set up security rules
3. Create indexes
4. Test basic CRUD operations

### Phase 2: Data Population
1. Import test data
2. Seed NGO data from verified sources
3. Create admin accounts

### Phase 3: Production
1. Enable security rules
2. Set up monitoring
3. Configure backup schedules
4. Set up alerting

---

**Document Version:** 1.0  
**Last Updated:** October 2025  
**Status:** Design Phase
