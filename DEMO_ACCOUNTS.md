# Demo Accounts for Testing

## 🎭 Test Credentials

### Donor Account
- **Email:** `demo.donor@fodo.app`
- **Password:** `Demo@123`
- **User Type:** Donor
- **Name:** Demo Donor
- **Phone:** 9876543210

### NGO Account
- **Email:** `demo.ngo@fodo.app`
- **Password:** `Demo@123`
- **User Type:** NGO
- **Name:** Hope Foundation
- **Phone:** 9876543211

---

## 🚀 Quick Test Flow

### Test as Donor:
1. Login with `demo.donor@fodo.app` / `Demo@123`
2. You'll see the **Donor Dashboard**
3. Click "Create Donation"
4. Fill in food details and submit
5. Track your donation status

### Test as NGO:
1. Logout from donor account
2. Login with `demo.ngo@fodo.app` / `Demo@123`
3. You'll see the **NGO Dashboard**
4. View "Available Donations"
5. Accept a donation
6. Update status as you collect it

---

## 📝 Manual Setup (if accounts don't exist)

### Option 1: Using Firebase Console

1. **Create Demo Donor:**
   - Go to Firebase Console > Authentication
   - Click "Add User"
   - Email: `demo.donor@fodo.app`
   - Password: `Demo@123`
   - Copy the User UID

2. **Add Donor Data to Realtime Database:**
   ```json
   {
     "users": {
       "DONOR_UID_HERE": {
         "userId": "DONOR_UID_HERE",
         "userType": "donor",
         "email": "demo.donor@fodo.app",
         "phoneNumber": "9876543210",
         "profileData": {
           "fullName": "Demo Donor",
           "organizationName": null
         },
         "location": {
           "address": "123 Demo Street",
           "city": "Mumbai",
           "state": "Maharashtra",
           "pincode": "400001",
           "coordinates": {
             "latitude": 19.0760,
             "longitude": 72.8777
           }
         },
         "createdAt": 1696147200000,
         "updatedAt": 1696147200000
       }
     }
   }
   ```

3. **Create Demo NGO:**
   - Firebase Console > Authentication
   - Click "Add User"
   - Email: `demo.ngo@fodo.app`
   - Password: `Demo@123`
   - Copy the User UID

4. **Add NGO User Data:**
   ```json
   {
     "users": {
       "NGO_UID_HERE": {
         "userId": "NGO_UID_HERE",
         "userType": "ngo",
         "email": "demo.ngo@fodo.app",
         "phoneNumber": "9876543211",
         "profileData": {
           "fullName": "NGO Admin",
           "organizationName": "Hope Foundation"
         },
         "location": {
           "address": "456 Service Road",
           "city": "Mumbai",
           "state": "Maharashtra",
           "pincode": "400002",
           "coordinates": {
             "latitude": 19.1136,
             "longitude": 72.8697
           }
         },
         "createdAt": 1696147200000,
         "updatedAt": 1696147200000
       }
     }
   }
   ```

5. **Add NGO Organization Data:**
   ```json
   {
     "ngos": {
       "NGO_UID_HERE": {
         "ngoId": "NGO_UID_HERE",
         "ngoName": "Hope Foundation",
         "registrationNumber": "NGO123456",
         "registrationType": "Trust",
         "contactPerson": {
           "name": "NGO Admin",
           "designation": "Director",
           "phone": "9876543211",
           "email": "demo.ngo@fodo.app"
         },
         "location": {
           "address": "456 Service Road",
           "city": "Mumbai",
           "state": "Maharashtra",
           "pincode": "400002",
           "coordinates": {
             "latitude": 19.1136,
             "longitude": 72.8697
           }
         },
         "serviceAreas": ["Mumbai", "Thane", "Navi Mumbai"],
         "verification": {
           "status": "verified",
           "verifiedAt": 1696147200000
         },
         "operatingHours": {
           "startTime": "09:00",
           "endTime": "18:00",
           "workingDays": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
           "available24x7": false
         },
         "statistics": {
           "totalCollections": 25,
           "totalPeopleFed": 500,
           "totalFoodWeight": 150.0,
           "completedCollections": 23,
           "cancelledCollections": 2,
           "averageResponseTime": 30.0,
           "rating": 4.5,
           "totalRatings": 20
         },
         "createdAt": 1696147200000,
         "updatedAt": 1696147200000
       }
     }
   }
   ```

### Option 2: Register Normally in App

If Firebase rules are set correctly:

1. **Register as Donor:**
   - Open app
   - Click "Register"
   - Select "I want to donate"
   - Fill form with demo details
   - Login

2. **Register as NGO:**
   - Logout
   - Click "Register"
   - Select "I'm an NGO"
   - Fill form with demo details
   - Login

---

## 🎬 Demo Donation Data (Optional)

To make the demo more realistic, add sample donations:

```json
{
  "donations": {
    "demo_donation_1": {
      "donationId": "demo_donation_1",
      "donorId": "DONOR_UID_HERE",
      "donorInfo": {
        "name": "Demo Donor",
        "phone": "9876543210"
      },
      "foodDetails": {
        "foodType": "cooked_food",
        "description": "Fresh rice, dal, and vegetables from party",
        "quantity": {
          "value": 50,
          "unit": "people"
        },
        "estimatedPeopleFed": 50,
        "photos": [],
        "bestBefore": 1696176000000,
        "isVegetarian": true,
        "isPackaged": false,
        "allergens": []
      },
      "pickupLocation": {
        "fullAddress": "123 Demo Street, Mumbai",
        "city": "Mumbai",
        "state": "Maharashtra",
        "pincode": "400001",
        "latitude": 19.0760,
        "longitude": 72.8777,
        "landmark": "Near ABC Mall",
        "instructions": "Contact before arriving"
      },
      "status": "pending",
      "timeline": {
        "createdAt": 1696147200000
      },
      "createdAt": 1696147200000,
      "updatedAt": 1696147200000
    }
  }
}
```

---

## 🔧 Quick Setup Commands

### Enable Firebase Test Mode
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```
⚠️ **Only for development!**

### Reset Authentication
If accounts have issues:
1. Firebase Console > Authentication
2. Find and delete old demo accounts
3. Create fresh ones

---

## ✅ Verification Checklist

After setup, verify:
- [ ] Can login as donor
- [ ] Donor dashboard loads
- [ ] Can create donation
- [ ] Can logout
- [ ] Can login as NGO
- [ ] NGO dashboard loads
- [ ] Can see available donations
- [ ] Can accept donation

---

## 🐛 Troubleshooting

**Issue:** "User not found"
- **Solution:** Check Authentication has the user

**Issue:** "No data on dashboard"
- **Solution:** Check Realtime Database has user/ngo data

**Issue:** "Permission denied"
- **Solution:** Update Firebase rules (see FIREBASE_TROUBLESHOOTING.md)

**Issue:** "Network error"
- **Solution:** Check internet, restart app

---

## 🎯 What You Should See

### Donor Dashboard:
- Welcome card with donor name
- Statistics (donations made, people fed)
- Quick action buttons
- Recent donations list
- Create donation button (FAB)

### NGO Dashboard:
- NGO name and verification badge
- Statistics (collections, people fed, rating)
- Quick action buttons
- Active pickups preview
- Available donations preview
- Find donations button (FAB)

---

## 📱 Screenshots Locations

Once logged in, you can:
1. Navigate through all screens
2. Take screenshots for Play Store
3. Test all features
4. Create real donation flows

---

**Ready to test! Use the credentials above to explore the app.** 🚀
