# FODO - API Documentation

## Overview

This document defines all API endpoints, request/response formats, and data models for the FODO application.

**Base URL:** `https://api.fodo.app/v1`  
**Protocol:** HTTPS  
**Content-Type:** `application/json`  
**Authentication:** Bearer Token (JWT)

---

## Table of Contents

1. [Authentication APIs](#authentication-apis)
2. [User APIs](#user-apis)
3. [Donor APIs](#donor-apis)
4. [NGO APIs](#ngo-apis)
5. [Donation APIs](#donation-apis)
6. [Transaction APIs](#transaction-apis)
7. [Notification APIs](#notification-apis)
8. [Rating APIs](#rating-apis)
9. [Common Response Formats](#common-response-formats)
10. [Error Codes](#error-codes)

---

## Authentication

All authenticated endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <access_token>
```

---

## 1. Authentication APIs

### 1.1 Register User (Donor)

**Endpoint:** `POST /auth/register/donor`

**Request Body:**
```json
{
  "fullName": "string",
  "email": "string",
  "phoneNumber": "string",
  "password": "string",
  "confirmPassword": "string",
  "address": {
    "fullAddress": "string",
    "city": "string",
    "state": "string",
    "pincode": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  "organizationName": "string (optional)"
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "User registered successfully. Please verify your email.",
  "data": {
    "userId": "string",
    "email": "string",
    "userType": "donor",
    "emailVerificationSent": true
  }
}
```

---

### 1.2 Register NGO

**Endpoint:** `POST /auth/register/ngo`

**Request Body:**
```json
{
  "ngoName": "string",
  "registrationNumber": "string",
  "registrationType": "string",
  "email": "string",
  "phoneNumber": "string",
  "password": "string",
  "confirmPassword": "string",
  "contactPerson": {
    "name": "string",
    "designation": "string",
    "phone": "string",
    "email": "string"
  },
  "address": {
    "fullAddress": "string",
    "city": "string",
    "state": "string",
    "pincode": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  "serviceAreas": ["array of strings"],
  "documents": [
    {
      "type": "registration_certificate",
      "base64Data": "string"
    }
  ]
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "NGO registered successfully. Your application is under review.",
  "data": {
    "userId": "string",
    "ngoId": "string",
    "email": "string",
    "userType": "ngo",
    "verificationStatus": "pending"
  }
}
```

---

### 1.3 Login

**Endpoint:** `POST /auth/login`

**Request Body:**
```json
{
  "email": "string",
  "password": "string",
  "deviceToken": "string (FCM token for notifications)"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "userId": "string",
    "userType": "string",
    "email": "string",
    "fullName": "string",
    "profilePhotoUrl": "string",
    "accessToken": "string",
    "refreshToken": "string",
    "expiresIn": 3600
  }
}
```

---

### 1.4 Verify Email

**Endpoint:** `POST /auth/verify-email`

**Request Body:**
```json
{
  "userId": "string",
  "verificationCode": "string"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Email verified successfully"
}
```

---

### 1.5 Send OTP (Phone Verification)

**Endpoint:** `POST /auth/send-otp`

**Request Body:**
```json
{
  "phoneNumber": "string"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "expiresIn": 300
  }
}
```

---

### 1.6 Verify OTP

**Endpoint:** `POST /auth/verify-otp`

**Request Body:**
```json
{
  "phoneNumber": "string",
  "otp": "string"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Phone number verified successfully"
}
```

---

### 1.7 Forgot Password

**Endpoint:** `POST /auth/forgot-password`

**Request Body:**
```json
{
  "email": "string"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Password reset link sent to your email"
}
```

---

### 1.8 Reset Password

**Endpoint:** `POST /auth/reset-password`

**Request Body:**
```json
{
  "resetToken": "string",
  "newPassword": "string",
  "confirmPassword": "string"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

---

### 1.9 Refresh Token

**Endpoint:** `POST /auth/refresh-token`

**Request Body:**
```json
{
  "refreshToken": "string"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "accessToken": "string",
    "refreshToken": "string",
    "expiresIn": 3600
  }
}
```

---

### 1.10 Logout

**Endpoint:** `POST /auth/logout`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 2. User APIs

### 2.1 Get User Profile

**Endpoint:** `GET /users/profile`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "userId": "string",
    "userType": "string",
    "email": "string",
    "phoneNumber": "string",
    "profileData": {
      "fullName": "string",
      "photoUrl": "string",
      "organizationName": "string",
      "bio": "string"
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
    "statistics": {
      "totalDonations": "number",
      "totalPeopleFed": "number",
      "impactScore": "number"
    },
    "createdAt": "timestamp"
  }
}
```

---

### 2.2 Update User Profile

**Endpoint:** `PUT /users/profile`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "fullName": "string",
  "photoUrl": "string",
  "bio": "string",
  "address": {
    "fullAddress": "string",
    "city": "string",
    "state": "string",
    "pincode": "string"
  }
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "userId": "string",
    "updatedFields": ["array of updated fields"]
  }
}
```

---

### 2.3 Upload Profile Photo

**Endpoint:** `POST /users/profile/photo`

**Headers:** `Authorization: Bearer <token>`

**Content-Type:** `multipart/form-data`

**Request Body:**
```
photo: File
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Photo uploaded successfully",
  "data": {
    "photoUrl": "string",
    "thumbnailUrl": "string"
  }
}
```

---

### 2.4 Change Password

**Endpoint:** `PUT /users/change-password`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "currentPassword": "string",
  "newPassword": "string",
  "confirmPassword": "string"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

### 2.5 Delete Account

**Endpoint:** `DELETE /users/account`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "password": "string",
  "reason": "string (optional)"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Account deleted successfully"
}
```

---

## 3. Donor APIs

### 3.1 Get Donor Statistics

**Endpoint:** `GET /donor/statistics`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "totalDonations": "number",
    "activeDonations": "number",
    "completedDonations": "number",
    "totalPeopleFed": "number",
    "totalFoodDonated": "number (in kg)",
    "impactScore": "number",
    "recentActivity": [
      {
        "donationId": "string",
        "status": "string",
        "date": "timestamp"
      }
    ]
  }
}
```

---

### 3.2 Get Donation History

**Endpoint:** `GET /donor/donations`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `status` (optional): Filter by status
- `page` (default: 1): Page number
- `limit` (default: 20): Items per page
- `sortBy` (default: createdAt): Sort field
- `order` (default: desc): Sort order

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "donations": [
      {
        "donationId": "string",
        "foodType": "string",
        "quantity": "number",
        "status": "string",
        "ngoName": "string",
        "createdAt": "timestamp",
        "completedAt": "timestamp",
        "peopleFed": "number"
      }
    ],
    "pagination": {
      "currentPage": "number",
      "totalPages": "number",
      "totalItems": "number",
      "itemsPerPage": "number"
    }
  }
}
```

---

## 4. NGO APIs

### 4.1 Get NGO Profile

**Endpoint:** `GET /ngo/profile`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "ngoId": "string",
    "ngoName": "string",
    "registrationNumber": "string",
    "email": "string",
    "phoneNumber": "string",
    "contactPerson": {
      "name": "string",
      "designation": "string",
      "phone": "string"
    },
    "verification": {
      "status": "string",
      "verifiedAt": "timestamp"
    },
    "statistics": {
      "totalCollections": "number",
      "totalPeopleFed": "number",
      "rating": "number",
      "successRate": "number"
    },
    "operatingDetails": {
      "serviceAreas": ["array"],
      "operatingHours": "object"
    }
  }
}
```

---

### 4.2 Update NGO Profile

**Endpoint:** `PUT /ngo/profile`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "contactPerson": {
    "name": "string",
    "designation": "string",
    "phone": "string"
  },
  "serviceAreas": ["array"],
  "operatingHours": {
    "monday": {"open": "09:00", "close": "18:00"}
  },
  "serviceCapacity": {
    "vehicleAvailable": "boolean",
    "teamSize": "number"
  }
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "NGO profile updated successfully"
}
```

---

### 4.3 Get NGO Statistics

**Endpoint:** `GET /ngo/statistics`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `period` (optional): daily, weekly, monthly, yearly

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "totalCollections": "number",
    "activePickups": "number",
    "completedToday": "number",
    "totalPeopleFed": "number",
    "averageResponseTime": "number (minutes)",
    "rating": "number",
    "successRate": "number (%)",
    "monthlyTrend": [
      {
        "month": "string",
        "collections": "number",
        "peopleFed": "number"
      }
    ]
  }
}
```

---

### 4.4 Get Collection History

**Endpoint:** `GET /ngo/collections`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `status` (optional): Filter by status
- `page` (default: 1)
- `limit` (default: 20)
- `fromDate` (optional): Filter from date
- `toDate` (optional): Filter to date

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "collections": [
      {
        "donationId": "string",
        "donorName": "string",
        "foodType": "string",
        "quantity": "number",
        "pickupAddress": "string",
        "status": "string",
        "acceptedAt": "timestamp",
        "completedAt": "timestamp",
        "peopleFed": "number"
      }
    ],
    "pagination": {
      "currentPage": "number",
      "totalPages": "number",
      "totalItems": "number"
    }
  }
}
```

---

## 5. Donation APIs

### 5.1 Create Donation Request

**Endpoint:** `POST /donations`

**Headers:** `Authorization: Bearer <token>`

**Content-Type:** `multipart/form-data`

**Request Body:**
```
foodType: string
description: string
quantity: number
quantityUnit: string
estimatedPeopleFed: number
photos[]: File[]
address: JSON string
availableFrom: timestamp
availableUntil: timestamp
specialInstructions: string (optional)
contactPhone: string
alternatePhone: string (optional)
isUrgent: boolean
needsContainers: boolean
dietaryInfo: JSON string
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "Donation request created successfully",
  "data": {
    "donationId": "string",
    "status": "created",
    "createdAt": "timestamp",
    "expiresAt": "timestamp"
  }
}
```

---

### 5.2 Get Donation Details

**Endpoint:** `GET /donations/:donationId`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "donationId": "string",
    "donorInfo": {
      "name": "string",
      "phone": "string",
      "organizationName": "string"
    },
    "foodDetails": {
      "foodType": "string",
      "description": "string",
      "quantity": {
        "value": "number",
        "unit": "string"
      },
      "estimatedPeopleFed": "number",
      "photos": ["array of URLs"],
      "dietaryInfo": "object"
    },
    "pickupDetails": {
      "address": "object",
      "availableFrom": "timestamp",
      "availableUntil": "timestamp",
      "specialInstructions": "string"
    },
    "status": "string",
    "ngoInfo": {
      "ngoId": "string",
      "ngoName": "string",
      "acceptedAt": "timestamp"
    },
    "tracking": {
      "viewCount": "number",
      "estimatedArrivalTime": "timestamp"
    },
    "createdAt": "timestamp"
  }
}
```

---

### 5.3 Get Nearby Donations (NGO)

**Endpoint:** `GET /donations/nearby`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `latitude`: Current latitude
- `longitude`: Current longitude
- `radius` (default: 10): Search radius in km
- `foodType` (optional): Filter by food type
- `minQuantity` (optional): Minimum quantity
- `maxQuantity` (optional): Maximum quantity
- `sortBy` (default: distance): Sort by distance, time, quantity
- `page` (default: 1)
- `limit` (default: 20)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "donations": [
      {
        "donationId": "string",
        "foodType": "string",
        "quantity": "number",
        "estimatedPeopleFed": "number",
        "photos": ["array"],
        "pickupAddress": "string",
        "distance": "number (in km)",
        "availableFrom": "timestamp",
        "availableUntil": "timestamp",
        "donorRating": "number",
        "isUrgent": "boolean"
      }
    ],
    "pagination": "object"
  }
}
```

---

### 5.4 Accept Donation (NGO)

**Endpoint:** `POST /donations/:donationId/accept`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "estimatedArrivalTime": "timestamp",
  "notes": "string (optional)"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Donation accepted successfully",
  "data": {
    "donationId": "string",
    "status": "accepted",
    "acceptedAt": "timestamp",
    "donorContactInfo": {
      "name": "string",
      "phone": "string",
      "address": "string"
    }
  }
}
```

---

### 5.5 Update Donation Status

**Endpoint:** `PUT /donations/:donationId/status`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "status": "string (in_transit, collected, distributed, completed)",
  "notes": "string (optional)",
  "peopleFed": "number (required for distributed status)",
  "distributionPhotos": ["array of base64 strings (optional)"]
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Status updated successfully",
  "data": {
    "donationId": "string",
    "status": "string",
    "updatedAt": "timestamp"
  }
}
```

---

### 5.6 Cancel Donation

**Endpoint:** `DELETE /donations/:donationId`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "reason": "string"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Donation cancelled successfully"
}
```

---

### 5.7 Search Donations

**Endpoint:** `GET /donations/search`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `query`: Search term
- `foodType`: Filter by type
- `city`: Filter by city
- `status`: Filter by status
- `fromDate`: From date
- `toDate`: To date

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "donations": ["array"],
    "totalResults": "number"
  }
}
```

---

## 6. Transaction APIs

### 6.1 Get Transaction Details

**Endpoint:** `GET /transactions/:transactionId`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "transactionId": "string",
    "donationId": "string",
    "donorId": "string",
    "ngoId": "string",
    "timeline": {
      "requestCreated": "timestamp",
      "requestAccepted": "timestamp",
      "pickupCompleted": "timestamp",
      "distributionCompleted": "timestamp"
    },
    "foodDetails": "object",
    "location": "object",
    "status": "string",
    "impact": {
      "peopleFed": "number",
      "foodSaved": "number"
    }
  }
}
```

---

### 6.2 Get Transaction History

**Endpoint:** `GET /transactions`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `status`: Filter by status
- `fromDate`: From date
- `toDate`: To date

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "transactions": ["array"],
    "pagination": "object"
  }
}
```

---

## 7. Notification APIs

### 7.1 Get Notifications

**Endpoint:** `GET /notifications`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 20)
- `unreadOnly` (default: false)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "notificationId": "string",
        "type": "string",
        "title": "string",
        "body": "string",
        "data": "object",
        "status": "string",
        "readAt": "timestamp",
        "createdAt": "timestamp"
      }
    ],
    "unreadCount": "number",
    "pagination": "object"
  }
}
```

---

### 7.2 Mark Notification as Read

**Endpoint:** `PUT /notifications/:notificationId/read`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

---

### 7.3 Mark All as Read

**Endpoint:** `PUT /notifications/mark-all-read`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "All notifications marked as read"
}
```

---

### 7.4 Delete Notification

**Endpoint:** `DELETE /notifications/:notificationId`

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Notification deleted successfully"
}
```

---

### 7.5 Update Notification Preferences

**Endpoint:** `PUT /notifications/preferences`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "pushEnabled": "boolean",
  "emailEnabled": "boolean",
  "smsEnabled": "boolean",
  "donationUpdates": "boolean",
  "promotions": "boolean"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Notification preferences updated"
}
```

---

## 8. Rating APIs

### 8.1 Submit Rating

**Endpoint:** `POST /ratings`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "transactionId": "string",
  "donationId": "string",
  "ratedToUserId": "string",
  "rating": {
    "score": "number (1-5)",
    "review": "string (optional)",
    "categories": {
      "communication": "number (1-5)",
      "timeliness": "number (1-5)",
      "foodQuality": "number (1-5)"
    }
  }
}
```

**Response:** `201 Created`
```json
{
  "success": true,
  "message": "Rating submitted successfully",
  "data": {
    "ratingId": "string",
    "score": "number"
  }
}
```

---

### 8.2 Get Ratings for User

**Endpoint:** `GET /ratings/user/:userId`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page` (default: 1)
- `limit` (default: 10)

**Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "averageRating": "number",
    "totalRatings": "number",
    "ratings": [
      {
        "ratingId": "string",
        "ratedBy": "string",
        "score": "number",
        "review": "string",
        "createdAt": "timestamp"
      }
    ],
    "pagination": "object"
  }
}
```

---

### 8.3 Update Rating

**Endpoint:** `PUT /ratings/:ratingId`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "score": "number",
  "review": "string"
}
```

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "Rating updated successfully"
}
```

---

## Common Response Formats

### Success Response
```json
{
  "success": true,
  "message": "string",
  "data": "object or array"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "string",
    "message": "string",
    "details": "object (optional)"
  }
}
```

### Pagination Format
```json
{
  "currentPage": 1,
  "totalPages": 10,
  "totalItems": 200,
  "itemsPerPage": 20,
  "hasNextPage": true,
  "hasPreviousPage": false
}
```

---

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `AUTH_001` | 401 | Invalid credentials |
| `AUTH_002` | 401 | Token expired |
| `AUTH_003` | 401 | Invalid token |
| `AUTH_004` | 403 | Email not verified |
| `AUTH_005` | 403 | Account suspended |
| `AUTH_006` | 400 | Password too weak |
| `USER_001` | 404 | User not found |
| `USER_002` | 409 | Email already exists |
| `USER_003` | 409 | Phone already exists |
| `USER_004` | 400 | Invalid user type |
| `NGO_001` | 403 | NGO not verified |
| `NGO_002` | 400 | Invalid registration number |
| `DONATION_001` | 404 | Donation not found |
| `DONATION_002` | 403 | Not authorized to access donation |
| `DONATION_003` | 400 | Donation already accepted |
| `DONATION_004` | 400 | Donation expired |
| `DONATION_005` | 400 | Invalid status transition |
| `RATING_001` | 400 | Already rated |
| `RATING_002` | 403 | Cannot rate own donation |
| `FILE_001` | 400 | File too large |
| `FILE_002` | 400 | Invalid file type |
| `VALIDATION_001` | 400 | Missing required fields |
| `VALIDATION_002` | 400 | Invalid data format |
| `SERVER_001` | 500 | Internal server error |
| `SERVER_002` | 503 | Service temporarily unavailable |

---

## Rate Limiting

- **General endpoints:** 100 requests per minute per user
- **Authentication endpoints:** 10 requests per minute per IP
- **File upload endpoints:** 20 requests per minute per user

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1635789600
```

---

## Webhook Events (Optional for future)

NGOs and Donors can register webhooks to receive real-time updates:

### Webhook Payload Format
```json
{
  "event": "donation.accepted",
  "timestamp": "2025-10-01T12:00:00Z",
  "data": {
    "donationId": "string",
    "ngoId": "string",
    "acceptedAt": "timestamp"
  }
}
```

### Available Events
- `donation.created`
- `donation.accepted`
- `donation.collected`
- `donation.distributed`
- `donation.completed`
- `donation.cancelled`
- `ngo.verified`

---

## API Versioning

The API uses URL versioning. Current version is `v1`.

```
https://api.fodo.app/v1/donations
```

When breaking changes are introduced, a new version will be released:
```
https://api.fodo.app/v2/donations
```

---

## Testing Endpoints

**Base URL (Staging):** `https://api-staging.fodo.app/v1`

Test credentials will be provided for development and testing.

---

**Document Version:** 1.0  
**Last Updated:** October 2025  
**API Version:** v1  
**Status:** Design Phase
