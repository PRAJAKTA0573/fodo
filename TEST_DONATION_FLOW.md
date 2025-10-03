# Quick Test Guide - Donation Flow

## Prerequisites
1. Have two test accounts ready (or create them):
   - **Donor Account**: Register as Donor
   - **NGO Account**: Register as NGO

2. Both accounts should have valid location data

---

## Step-by-Step Test

### Part 1: Donor Creates Donation

1. **Login as Donor**
   ```
   Login → Select "Continue as Donor"
   ```

2. **Create New Donation**
   ```
   Dashboard → Tap FAB "New Donation" (+)
   ```

3. **Fill Donation Form**
   - **Step 1 - Food Details:**
     - Food Type: Cooked Food
     - Description: "Rice, Curry, Bread"
     - Quantity: 10 People
     - Vegetarian: Yes
     - Best Before: Select future time
     - Tap "Next"
   
   - **Step 2 - Photos:** (if images enabled)
     - Skip or add photos
     - Tap "Next"
   
   - **Step 3 - Location:**
     - Select pickup location
     - Tap "Next"
   
   - **Step 4 - Review:**
     - Review details
     - Tap "Submit"

4. **Verify Donation Created**
   ```
   ✅ Success message: "Donation created successfully!"
   ✅ Redirected to Dashboard
   ✅ See new donation in "Active Donations"
   ✅ Status shows: "Available" (Blue chip)
   ```

5. **View Donation Details**
   ```
   Tap on donation card → Details page opens
   ✅ Status banner: "Available" (Blue)
   ✅ Food details displayed
   ✅ Location displayed
   ✅ Timeline shows "Created" entry
   ```

---

### Part 2: NGO Views & Accepts Donation

6. **Logout & Login as NGO**
   ```
   Dashboard → Profile/Menu → Logout
   Login → Select "Continue as NGO"
   ```

7. **View Available Donations**
   ```
   NGO Dashboard → Tap "Available Donations"
   ✅ See list of available donations
   ✅ Your test donation should be visible
   ```

8. **View Donation Details**
   ```
   Tap on your test donation
   ✅ See complete food details
   ✅ See pickup location
   ✅ See donor contact info
   ✅ Green button at bottom: "Accept This Donation"
   ```

9. **Accept the Donation**
   ```
   Tap "Accept This Donation"
   → Dialog: "When can you collect this donation?"
   → Tap on time field
   → Select date (today or tomorrow)
   → Select time (e.g., 2:00 PM)
   → Tap "Confirm"
   
   ✅ Success message: "Donation accepted successfully!"
   ✅ Redirected back to previous screen
   ```

---

### Part 3: Donor Sees Acceptance

10. **Logout & Login as Donor Again**
    ```
    Logout → Login as Donor → Select "Continue as Donor"
    ```

11. **Check Dashboard**
    ```
    Dashboard → Look at "Active Donations"
    ✅ Status chip: "Accepted" (Orange color) ✅
    ```

12. **View Donation Details**
    ```
    Tap on donation → Details page
    ✅ Status banner: "Accepted" (Orange)
    
    ✅ New section: "Accepted By"
       - NGO Name: [Your NGO name]
       - Contact: [Contact person]
       - Phone: [Phone number]
       - Est. Pickup: [Date & time you selected]
    
    ✅ Timeline shows "Accepted" entry with timestamp
    ```

---

## Expected Results Summary

### Donor View After Acceptance:

**Dashboard Card:**
```
┌─────────────────────────────────┐
│ 🍽️  Cooked Food                │
│                                  │
│ Rice, Curry, Bread              │
│ Jan 15, 2025 • 10:30 AM         │
│                                  │
│              [Accepted] 🟠      │
└─────────────────────────────────┘
```

**Details Page:**
```
╔════════════════════════════════════╗
║        🟠 Accepted                 ║
╚════════════════════════════════════╝

📋 Food Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Type: Cooked Food
Description: Rice, Curry, Bread
Quantity: 10 People
Vegetarian: Yes
...

🏢 Accepted By ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NGO: Food Bank India
Contact: Rajesh Kumar
Phone: +91-9876543210
Est. Pickup: Jan 15, 2025 • 02:00 PM

📍 Pickup Location
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
123 Main Street
Mumbai, Maharashtra - 400001

📅 Donation Timeline
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Created
   Jan 15, 2025 • 10:30 AM

✅ Made Visible
   Jan 15, 2025 • 10:30 AM

✅ Accepted ← NEW!
   Jan 15, 2025 • 11:45 AM
```

---

## Troubleshooting

### Issue: Donation not visible to NGO
**Check:**
- Donation status is `visible` (not `created`)
- NGO location is within search radius
- NGO has proper location data

### Issue: Status not updating for donor
**Check:**
- Refresh the page (pull down on dashboard)
- Check internet connection
- Real-time listener should auto-update

### Issue: Accept button not working
**Check:**
- NGO profile is complete
- NGO has required verification data
- Check console for errors

---

## What Happens Next?

After acceptance, NGO can:
1. Mark "On the Way" when traveling to pickup
2. Mark "Collected" when food is collected
3. Mark "Distributed" after distribution
4. Mark "Completed" when done

Each status update is visible to the donor in real-time!

---

## Quick Status Reference

| Who | Action | Result |
|-----|--------|--------|
| **Donor** | Creates donation | Status: "Available" (Blue) |
| **NGO** | Accepts donation | Status: "Accepted" (Orange) ✅ |
| **NGO** | Marks "On the Way" | Status: "On the Way" (Orange) |
| **NGO** | Marks "Collected" | Status: "Collected" (Purple) |
| **NGO** | Marks "Distributed" | Status: "Distributed" (Purple) |
| **NGO** | Marks "Completed" | Status: "Completed" (Green) |

All status changes are visible to both donor and NGO!

---

## Success Criteria ✅

Your test is successful if:
- ✅ Donor can create donation
- ✅ Donation shows "Available" status to donor
- ✅ NGO can see donation in available list
- ✅ NGO can accept donation with pickup time
- ✅ Donor sees "Accepted" status (Orange)
- ✅ Donor sees NGO details after acceptance
- ✅ Timeline shows acceptance timestamp

**All features are already implemented and working!** 🎉
