# Firebase Troubleshooting Guide

## Network Error during NGO Registration

If you're seeing "A network error (such as timeout, interrupted connection or unreachable host) has occurred" during NGO registration, follow these steps:

### 1. Check Internet Connection

**For Android Emulator:**
```bash
# Check if emulator has internet
adb shell ping -c 4 8.8.8.8

# If no internet, restart emulator or check network settings
```

### 2. Check Firebase Configuration

1. Verify `google-services.json` exists:
   - Location: `android/app/google-services.json`
   - Must be downloaded from Firebase Console

2. Verify `firebase_options.dart` is correct:
   - Run: `flutterfire configure` to regenerate if needed

### 3. Check Firebase Realtime Database Rules

Go to Firebase Console > Realtime Database > Rules

**For Development (Testing):**
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

**⚠️ WARNING**: The above rules are ONLY for development/testing!

**For Production:** Use the rules from `firebase_database_rules.json`

### 4. Check Debug Logs

When you run the app, look for these console logs:
```
🔵 Starting NGO registration for: [email]
🔵 Creating Firebase Auth user...
✅ Firebase Auth user created: [uid]
🔵 Saving user to database...
✅ User saved to database
🔵 Creating NGO entry...
✅ NGO entry created
🔵 Sending email verification...
🎉 NGO registration completed successfully!
```

If it stops at any step, that's where the issue is.

### 5. Common Issues & Solutions

#### Issue: "Permission denied" error
**Solution**: Update Firebase Realtime Database rules (see above)

#### Issue: "Network error" immediately
**Solution**: 
1. Check emulator internet connection
2. Restart emulator
3. Try on physical device

#### Issue: "Timeout" error
**Solution**:
1. Check Firebase project is active
2. Check billing (for production apps)
3. Try again with stable internet

#### Issue: "User created but database save fails"
**Solution**: This is a database rules issue. Set temporary open rules for testing.

### 6. Test Firebase Connection

Add this test function to check Firebase connection:

```dart
Future<void> testFirebaseConnection() async {
  try {
    final db = FirebaseDatabase.instance;
    await db.ref('test').set({
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'message': 'Connection test'
    });
    print('✅ Firebase connection successful!');
  } catch (e) {
    print('❌ Firebase connection failed: $e');
  }
}
```

### 7. Temporary Development Rules

For quick testing, use these permissive rules:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

**Remember to change to secure rules before production!**

### 8. Check Firebase Console

1. Go to Firebase Console
2. Navigate to Realtime Database
3. Check if data is being written
4. Check "Usage" tab for errors

### 9. Network Debugging

If on physical device:
- Check WiFi is enabled
- Check mobile data is enabled
- Try switching networks

If on emulator:
- Cold boot the emulator
- Check proxy settings
- Enable internet in emulator settings

### 10. Firebase Authentication Check

Ensure Firebase Authentication is enabled:
1. Firebase Console > Authentication > Sign-in method
2. Enable "Email/Password" provider
3. Save changes

## Quick Fix Checklist

- [ ] Internet connection working
- [ ] Firebase Realtime Database rules set to open (for testing)
- [ ] `google-services.json` in correct location
- [ ] Firebase Authentication Email/Password enabled
- [ ] App rebuilt after Firebase config changes
- [ ] Emulator/device restarted

## Still Not Working?

1. **Clean and rebuild:**
```bash
flutter clean
flutter pub get
flutter run
```

2. **Check Firebase project status:**
   - Go to Firebase Console
   - Verify project is active
   - Check quotas not exceeded

3. **Try different device/emulator:**
   - Sometimes emulator-specific issues

4. **Enable debug logging:**
   - Check console for detailed Firebase logs
   - Look for the 🔵, ✅, ❌ emoji logs

## Production Deployment

Before deploying:
1. ✅ Update database rules to secure version
2. ✅ Test with production rules
3. ✅ Remove all debug print statements
4. ✅ Enable crash reporting
5. ✅ Set up monitoring

## Need More Help?

- Check Firebase Status: https://status.firebase.google.com/
- Firebase Documentation: https://firebase.google.com/docs
- Flutter Fire: https://firebase.flutter.dev/
