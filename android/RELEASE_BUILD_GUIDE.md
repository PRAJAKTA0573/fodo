# Android Release Build Guide

## 1. Create Keystore

```bash
keytool -genkey -v -keystore ~/fodo-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fodo-key
```

**Important**: Save the keystore password and key password securely!

## 2. Configure key.properties

Create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=fodo-key
storeFile=PATH_TO_YOUR_KEYSTORE/fodo-release-key.jks
```

**Note**: Add `key.properties` to `.gitignore`!

## 3. Update android/app/build.gradle

The signing configuration is already set up in the gradle file.
Just ensure key.properties exists.

## 4. Build Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## 5. Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## 6. Test Release Build

```bash
flutter install --release
```

## Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+build_number
```

## Build Flavors (Optional)

For dev/staging/production:

```bash
flutter build apk --release --flavor production
```

## Optimization Flags

```bash
flutter build apk --release --shrink --obfuscate --split-debug-info=./build/debug-info
```

## File Sizes

- APK: ~30-50 MB (depends on assets)
- AAB: ~25-40 MB (Google Play optimizes this)

## Testing Checklist

- [ ] App launches without crashes
- [ ] Firebase works in release mode
- [ ] All features functional
- [ ] No debug logs visible
- [ ] Performance is good
- [ ] Icons and images load correctly
- [ ] Network calls work
- [ ] Permissions requested properly

## Play Store Preparation

See `PLAY_STORE_ASSETS.md` for required materials.
