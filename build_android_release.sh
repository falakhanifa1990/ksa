#!/bin/bash

# Airfryer Recipes - Android Release Build Script
# This script automates the process of creating a release APK for the Airfryer Recipes app

echo "======================================"
echo "Airfryer Recipes - Android Build Tool"
echo "======================================"
echo

# Check Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Check Java is installed
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed or not in PATH"
    echo "Please install JDK from https://openjdk.java.net/"
    exit 1
fi

# Check for keystore file
if [ ! -f "android/key.properties" ]; then
    echo "Warning: No key.properties file found in android/ directory."
    echo "This is required for signing the release APK."
    echo 
    read -p "Do you want to create a debug build instead? (y/n): " debug_choice
    
    if [ "$debug_choice" != "y" ]; then
        echo
        echo "Please follow these steps to create a keystore file:"
        echo "1. Run: keytool -genkey -v -keystore ~/airfryer_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias airfryer"
        echo "2. Create android/key.properties with your keystore information"
        echo "3. Run this script again"
        echo
        echo "See docs/release_build_guide.md for more details"
        exit 1
    fi
    
    BUILD_TYPE="--debug"
    echo "Building debug APK instead..."
else
    BUILD_TYPE="--release"
    echo "Found signing configuration. Building release APK..."
fi

echo
echo "Step 1/4: Cleaning previous builds..."
flutter clean

echo
echo "Step 2/4: Getting dependencies..."
flutter pub get

echo
echo "Step 3/4: Building Android APK${BUILD_TYPE}..."
flutter build apk $BUILD_TYPE

# Check if build was successful
if [ $? -ne 0 ]; then
    echo
    echo "Error: Build failed. Please check the error messages above."
    exit 1
fi

echo
echo "Step 4/4: Build completed successfully!"

if [ "$BUILD_TYPE" == "--release" ]; then
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
else
    APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
fi

echo
echo "APK file location: $APK_PATH"
echo "APK file size: $(du -h "$APK_PATH" | cut -f1)"

echo
echo "Want to install on a connected device?"
read -p "Install now? (y/n): " install_choice

if [ "$install_choice" == "y" ]; then
    echo "Installing on connected device..."
    flutter install
    echo "Done!"
fi

echo
echo "To build an App Bundle for Play Store release, run:"
echo "flutter build appbundle --release"
echo
echo "Thank you for using the Airfryer Recipes build tool!"