# Package Dependencies Setup Guide

## Required Swift Packages

Add the following packages to your Xcode project via **File > Add Package Dependencies**:

### 1. Firebase iOS SDK
- **URL**: `https://github.com/firebase/firebase-ios-sdk`
- **Version**: Latest stable (10.x or later)
- **Products to add**:
  - FirebaseAnalytics
  - FirebaseCrashlytics
  - FirebaseRemoteConfig
  - FirebaseAuth (optional)
  - FirebaseFirestore (optional)

### 2. RevenueCat SDK
- **URL**: `https://github.com/RevenueCat/purchases-ios`
- **Version**: Latest stable (4.x or later)
- **Products to add**:
  - RevenueCat

### 3. Superwall SDK
- **URL**: `https://github.com/superwall-me/superwall-ios`
- **Version**: Latest stable (3.x or later)
- **Products to add**:
  - SuperwallKit

## Installation Steps

1. Open `AfterSplit.xcodeproj` in Xcode
2. Go to **File > Add Package Dependencies**
3. Add each package URL above
4. Select the products listed for each package
5. Ensure all packages are added to the **AfterSplit** target

## Alternative: Using Package.swift (if converting to SPM)

If you prefer to use a Package.swift file, create one in the project root with the dependencies listed above.
