# Role Selection Feature

## Overview
Implemented a post-login role selection screen that allows users to choose whether they want to continue as a **Donor** or **NGO** after logging in.

## Implementation Details

### Files Created
1. **`lib/features/auth/presentation/pages/role_selection_page.dart`**
   - Beautiful UI with two role cards (Donor and NGO)
   - Feature lists for each role
   - Visual feedback on selection
   - Loading state while updating role
   - Logout option available

### Files Modified

1. **`lib/main.dart`**
   - Updated routing logic to show `RoleSelectionPage` after successful login
   - Removed direct routing to dashboards based on stored userType
   - Cleaned up unused imports

2. **`lib/features/auth/presentation/providers/auth_provider.dart`**
   - Added `updateUserType(UserType newUserType)` method
   - Handles user type updates and notifies listeners

3. **`lib/features/auth/data/repositories/auth_repository_impl.dart`**
   - Added `updateUserType()` method to repository
   - Updates userType in Firebase Realtime Database
   - Returns updated user model

## How It Works

### User Flow
1. User logs in successfully (email/password or Google Sign-In)
2. App shows **Role Selection Page**
3. User sees two cards:
   - **Donor Card** (Green)
     - Create food donations
     - Track your impact
     - Connect with NGOs
     - View donation history
   - **NGO Card** (Blue)
     - Browse available donations
     - Accept and collect food
     - Track distributions
     - Build your reputation
4. User taps on their preferred role
5. Loading indicator appears: "Setting up your account..."
6. User type is updated in database
7. User is navigated to appropriate dashboard:
   - Donor → `DonorDashboardPage`
   - NGO → `NGODashboardPage`

### Database Update
- Updates `userType` field in `users/{userId}` node
- Updates `updatedAt` timestamp
- Fetches and returns updated user data

### UI Features
- **Visual Selection**: Selected card has:
  - Elevated shadow (elevation 8)
  - Colored border
  - Check circle icon
  - "Selected" button text
- **Info Banner**: Informs users they can change role later from settings
- **Logout Option**: Users can logout from the role selection screen
- **Loading State**: Shows progress indicator during update

## Configuration

The feature is always active after login. Users will always see the role selection screen, regardless of their previous userType in the database.

### To Disable (Optional)
If you want to revert to automatic routing based on stored userType:

1. In `lib/main.dart`, replace the role selection logic:
```dart
// Current (Role Selection):
if (authProvider.isAuthenticated) {
  return const RoleSelectionPage();
}

// Change back to:
if (authProvider.isAuthenticated) {
  final userType = authProvider.currentUser?.userType;
  
  if (userType == UserType.donor) {
    return const DonorDashboardPage();
  } else if (userType == UserType.ngo) {
    return const NGODashboardPage();
  } else {
    return const HomePage();
  }
}
```

## Benefits

1. **Flexibility**: Users can switch roles easily
2. **User Control**: Gives users choice instead of automatic routing
3. **Clear UX**: Users understand what each role offers before choosing
4. **Easy Role Switching**: Foundation for a settings feature to change roles later

## Future Enhancements

1. **Settings Page**: Add "Change Role" option in user settings
2. **Role-Specific Onboarding**: Show different onboarding flows based on selected role
3. **Role History**: Track when users change roles
4. **Role Verification**: For NGOs, trigger verification process on role selection
5. **Conditional Display**: Only show role selection for new users, not returning users

## Testing

To test the feature:
1. Login with any account
2. You should see the Role Selection screen
3. Tap on "Continue as Donor" or "Continue as NGO"
4. Verify you're taken to the correct dashboard
5. Check Firebase Database to confirm userType was updated

## Notes

- The role selection happens **every time** a user logs in with the current implementation
- Previous userType from registration is overridden by the selection
- Users can logout from the role selection screen if they change their mind
- The update is saved in Firebase, so it persists across sessions

## Image Feature Status

Note: Image upload and display features are currently **disabled** via the `AppConstants.imagesEnabled = false` flag. The role selection feature works independently of this setting.
