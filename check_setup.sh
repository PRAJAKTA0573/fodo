#!/bin/bash

# FODO App Setup Checker
# This script checks if your app is properly configured

echo "🔍 Checking FODO App Configuration..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Android Manifest
echo "📱 Checking Android Configuration..."
if grep -q "YOUR_GOOGLE_MAPS_API_KEY_HERE" android/app/src/main/AndroidManifest.xml; then
    echo -e "${RED}❌ Google Maps API key not configured in AndroidManifest.xml${NC}"
    echo -e "${YELLOW}   Please replace YOUR_GOOGLE_MAPS_API_KEY_HERE with your actual API key${NC}"
    ANDROID_OK=false
else
    if grep -q "com.google.android.geo.API_KEY" android/app/src/main/AndroidManifest.xml; then
        echo -e "${GREEN}✅ Google Maps API key found in AndroidManifest.xml${NC}"
        ANDROID_OK=true
    else
        echo -e "${RED}❌ Google Maps API key meta-data missing in AndroidManifest.xml${NC}"
        ANDROID_OK=false
    fi
fi

echo ""

# Check iOS AppDelegate
echo "🍎 Checking iOS Configuration..."
if [ -f "ios/Runner/AppDelegate.swift" ]; then
    if grep -q "YOUR_GOOGLE_MAPS_API_KEY_HERE" ios/Runner/AppDelegate.swift; then
        echo -e "${RED}❌ Google Maps API key not configured in AppDelegate.swift${NC}"
        echo -e "${YELLOW}   Please replace YOUR_GOOGLE_MAPS_API_KEY_HERE with your actual API key${NC}"
        IOS_OK=false
    else
        if grep -q "GMSServices.provideAPIKey" ios/Runner/AppDelegate.swift; then
            echo -e "${GREEN}✅ Google Maps API key found in AppDelegate.swift${NC}"
            IOS_OK=true
        else
            echo -e "${RED}❌ GMSServices configuration missing in AppDelegate.swift${NC}"
            IOS_OK=false
        fi
    fi
else
    echo -e "${RED}❌ AppDelegate.swift not found${NC}"
    IOS_OK=false
fi

echo ""

# Check permissions
echo "🔐 Checking Permissions..."
if grep -q "ACCESS_FINE_LOCATION" android/app/src/main/AndroidManifest.xml; then
    echo -e "${GREEN}✅ Location permissions configured for Android${NC}"
else
    echo -e "${RED}❌ Location permissions missing in AndroidManifest.xml${NC}"
fi

if grep -q "NSLocationWhenInUseUsageDescription" ios/Runner/Info.plist; then
    echo -e "${GREEN}✅ Location permissions configured for iOS${NC}"
else
    echo -e "${RED}❌ Location permissions missing in Info.plist${NC}"
fi

echo ""
echo "📦 Checking Dependencies..."
if [ -f "pubspec.yaml" ]; then
    if grep -q "google_maps_flutter:" pubspec.yaml; then
        echo -e "${GREEN}✅ google_maps_flutter package found${NC}"
    else
        echo -e "${RED}❌ google_maps_flutter package not found${NC}"
    fi
    
    if grep -q "geolocator:" pubspec.yaml; then
        echo -e "${GREEN}✅ geolocator package found${NC}"
    else
        echo -e "${RED}❌ geolocator package not found${NC}"
    fi
    
    if grep -q "permission_handler:" pubspec.yaml; then
        echo -e "${GREEN}✅ permission_handler package found${NC}"
    else
        echo -e "${RED}❌ permission_handler package not found${NC}"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Final summary
if [ "$ANDROID_OK" = true ] && [ "$IOS_OK" = true ]; then
    echo -e "${GREEN}✅ Configuration looks good! You can run: flutter run${NC}"
else
    echo -e "${YELLOW}⚠️  Configuration incomplete. Please follow the instructions in SETUP_GOOGLE_MAPS_API.md${NC}"
    echo ""
    echo "Quick steps:"
    echo "1. Get API key from: https://console.cloud.google.com/"
    echo "2. Replace YOUR_GOOGLE_MAPS_API_KEY_HERE in:"
    echo "   - android/app/src/main/AndroidManifest.xml"
    echo "   - ios/Runner/AppDelegate.swift"
    echo "3. Run: flutter clean && flutter pub get"
    echo "4. Run: flutter run"
fi

echo ""
