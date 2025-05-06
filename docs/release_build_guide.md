# Airfryer Recipes App - Release Build Guide

This guide outlines the steps required to build a release APK of the Airfryer Recipes app for Android.

## Prerequisites

Before you begin, make sure you have the following installed and configured on your local machine:

1. **Flutter SDK** - Follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install)
2. **Android Studio** - With Android SDK installed
3. **Java Development Kit (JDK)** - Version 8 or newer

## Step 1: Clone the Repository

Clone the repository to your local machine:

```bash
git clone [your-repository-url]
cd airfryer-recipes
```

## Step 2: Generate a Signing Key

To publish an Android app, you need to sign it with a digital key. If you don't have a keystore yet:

```bash
keytool -genkey -v -keystore ~/airfryer_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias airfryer
```

You'll be prompted to enter passwords and certificate information.

## Step 3: Configure the Signing Keys

Create a `key.properties` file in the `android/` directory with the following content (use your own values):

```
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=airfryer
storeFile=/path/to/your/airfryer_key.jks
```

Make sure to replace `/path/to/your/airfryer_key.jks` with the actual path to the keystore file you created.

## Step 4: Update App Version (Optional)

If you want to update the app version, edit the `pubspec.yaml` file:

```yaml
version: 1.0.0+1  # Format is <version_number>+<build_number>
```

## Step 5: Generate App Icons (Optional)

The app is already configured to use the icon at `assets/images/app_icon.png`. If you want to change it, replace this file with your own 1024x1024 PNG icon and run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## Step 6: Clean and Build the Release APK

Run the following commands to clean any previous builds and create a new release APK:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

For an AppBundle (preferred for Play Store submission):

```bash
flutter build appbundle --release
```

## Step 7: Locate the APK File

After the build completes successfully, the APK file can be found at:

```
build/app/outputs/flutter-apk/app-release.apk
```

And the App Bundle (if you built it) will be at:

```
build/app/outputs/bundle/release/app-release.aab
```

## Testing the Release APK

It's important to test the release version before distributing it:

1. Install the APK on a physical device:
   ```bash
   flutter install
   ```

2. Or, manually install the APK:
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

## Troubleshooting Common Issues

### Keystore Issues

If you encounter issues with the keystore:
- Make sure the path to the keystore file is correct in `key.properties`
- Verify that the passwords and alias match what you created
- Check that the `key.properties` file is in the correct location (in the `android/` directory)

### Build Failures

If the build fails:
- Check Gradle logs for specific errors
- Ensure all dependencies are correctly set in `pubspec.yaml`
- Make sure the Android SDK is properly installed and configured
- Run `flutter doctor` to identify any system configuration issues

### Performance Issues

If the app performance in release mode is not satisfactory:
- Check for excessive debug statements which should be removed in release builds
- Ensure assets are optimized (especially images)
- Consider running a profiler to identify performance bottlenecks

## Distribution

Once you have a working release APK or App Bundle, you can distribute it through:

1. **Google Play Store** - Preferred method, requires a developer account
2. **Manual distribution** - Share the APK directly with users (less secure)
3. **Alternative app stores** - Amazon App Store, Samsung Galaxy Store, etc.

## Security Considerations

Remember that the app signing key is extremely important:
- Never share your keystore file or its passwords
- Back up your keystore file securely
- If you lose your keystore, you won't be able to push updates to your app under the same listing on the Play Store

---

## App-Specific Notes

### Database Migration

The Airfryer Recipes app uses SQLite for local data storage. If you're updating from a previous version:
- Make sure any database migration code is properly implemented
- Test thoroughly to ensure user data is preserved when upgrading

### External Services

This app currently operates fully offline with no external service dependencies. If future versions implement external services:
- Ensure API keys are properly secured
- Add appropriate network security configurations
- Update the privacy policy to reflect data usage