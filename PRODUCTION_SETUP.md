# Production Setup Guide for AfterSplit

This guide will walk you through setting up AfterSplit for production deployment with subscriptions, Firebase, RevenueCat, and Superwall.

## Prerequisites

- Xcode 16.0 or later
- iOS 18.0+ deployment target
- Apple Developer account
- Firebase account
- RevenueCat account
- Superwall account

## Step 1: Firebase Setup

### 1.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: "AfterSplit"
4. Enable Google Analytics (recommended)
5. Create the project

### 1.2 Add iOS App to Firebase

1. In Firebase Console, click "Add app" > iOS
2. Enter bundle ID: `leadpresence.AfterSplit`
3. Download `GoogleService-Info.plist`
4. Add `GoogleService-Info.plist` to your Xcode project root (same level as `AfterSplit.xcodeproj`)
5. Ensure it's added to the target in Xcode

### 1.3 Enable Firebase Services

1. **Analytics**: Automatically enabled
2. **Crashlytics**: 
   - Go to Firebase Console > Crashlytics
   - Follow setup instructions
   - Add Crashlytics script to Build Phases
3. **Remote Config**:
   - Go to Firebase Console > Remote Config
   - Create default values (see Remote Config section below)

## Step 2: RevenueCat Setup

### 2.1 Create RevenueCat Project

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create a new project: "AfterSplit"
3. Add iOS app with bundle ID: `leadpresence.AfterSplit`

### 2.2 Configure Products in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to your app > Features > In-App Purchases
3. Create subscription group: "AfterSplit Premium"
4. Create three products:

   **Product 1: 7-Day Trial**
   - Product ID: `trial_7days_039`
   - Type: Auto-Renewable Subscription
   - Subscription Group: AfterSplit Premium
   - Price: $0.39
   - Subscription Duration: 1 week
   - Free Trial: 7 days

   **Product 2: Monthly**
   - Product ID: `monthly_399`
   - Type: Auto-Renewable Subscription
   - Subscription Group: AfterSplit Premium
   - Price: $3.99/month

   **Product 3: Yearly**
   - Product ID: `yearly_2999`
   - Type: Auto-Renewable Subscription
   - Subscription Group: AfterSplit Premium
   - Price: $29.99/year

### 2.3 Configure RevenueCat

1. In RevenueCat Dashboard:
   - Go to Products
   - Add the three products created above
   - Create entitlement: `premium`
   - Attach all three products to the `premium` entitlement

2. Get your RevenueCat API Key:
   - Go to Project Settings > API Keys
   - Copy the public API key
   - Update `AppConfig.swift`:
     ```swift
     static var revenueCatAPIKey: String {
         return "YOUR_ACTUAL_API_KEY"
     }
     ```

## Step 3: Superwall Setup

### 3.1 Create Superwall Account

1. Go to [Superwall Dashboard](https://superwall.com/dashboard)
2. Create a new project: "AfterSplit"
3. Add iOS app with bundle ID: `leadpresence.AfterSplit`

### 3.2 Configure Superwall

1. Get your Superwall API Key:
   - Go to Settings > API Keys
   - Copy the API key
   - Update `AppConfig.swift`:
     ```swift
     static var superwallAPIKey: String {
         return "YOUR_ACTUAL_API_KEY"
     }
     ```

2. Connect RevenueCat:
   - In Superwall Dashboard, go to Integrations
   - Connect RevenueCat account
   - This allows Superwall to check subscription status

3. Create Paywall Campaigns:
   - Create campaigns for different trigger points:
     - After onboarding
     - Photo limit reached
     - Video limit reached
     - Premium feature access

## Step 4: Add Swift Packages

1. Open `AfterSplit.xcodeproj` in Xcode
2. Go to **File > Add Package Dependencies**
3. Add the following packages:

   **Firebase iOS SDK**
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Version: Latest stable
   - Products: FirebaseAnalytics, FirebaseCrashlytics, FirebaseRemoteConfig

   **RevenueCat SDK**
   - URL: `https://github.com/RevenueCat/purchases-ios`
   - Version: Latest stable
   - Products: RevenueCat

   **Superwall SDK**
   - URL: `https://github.com/superwall-me/superwall-ios`
   - Version: Latest stable
   - Products: SuperwallKit

## Step 5: Configure Remote Config

In Firebase Console > Remote Config, set these default values:

```
paywall_trigger_after_onboarding: true (Boolean)
free_tier_photo_limit: 10 (Number)
free_tier_video_limit: 3 (Number)
paywall_trigger_photo_limit: 5 (Number)
paywall_trigger_video_limit: 2 (Number)
enable_premium_filters: true (Boolean)
enable_premium_split_styles: true (Boolean)
trial_duration_days: 7 (Number)
```

## Step 6: Update App Configuration

1. Open `AfterSplit/Core/Configuration/AppConfig.swift`
2. Replace placeholder API keys with your actual keys:
   - RevenueCat API Key
   - Superwall API Key

## Step 7: Build Configuration

1. In Xcode, select your target
2. Go to **Build Phases**
3. Add Crashlytics script (if not already added):
   ```
   "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
   ```

## Step 8: Testing

### 8.1 Test with Sandbox Accounts

1. Create sandbox test accounts in App Store Connect
2. Sign out of App Store on test device
3. Run app and test purchase flow
4. Use sandbox account when prompted

### 8.2 Test Subscription Flows

- Test 7-day trial purchase
- Test monthly subscription
- Test yearly subscription
- Test restore purchases
- Test subscription expiration
- Test paywall triggers

## Step 9: App Store Connect Setup

### 9.1 App Information

- App Name: AfterSplit
- Category: Photo & Video
- Age Rating: 4+
- Privacy Policy URL: `https://aftersplit.com/privacy`
- Support URL: `https://aftersplit.com/support`

### 9.2 Subscription Information

- Subscription Group: AfterSplit Premium
- Free Trial: 7 days for $0.39
- Monthly: $3.99/month
- Yearly: $29.99/year

### 9.3 App Privacy

Answer privacy questions:
- Data collection: Analytics, Crash reports
- Data usage: App functionality, Analytics
- Data linked to user: No
- Tracking: Optional (with user permission)

## Step 10: Pre-Launch Checklist

- [ ] Firebase configured and tested
- [ ] RevenueCat products configured
- [ ] Superwall campaigns created
- [ ] API keys updated in AppConfig.swift
- [ ] GoogleService-Info.plist added
- [ ] All Swift packages added
- [ ] Subscription flows tested
- [ ] Paywall triggers tested
- [ ] Free tier limitations working
- [ ] Analytics tracking verified
- [ ] Crashlytics reporting verified
- [ ] Privacy policy and terms added
- [ ] App Store Connect configured
- [ ] TestFlight build uploaded
- [ ] Beta testing completed

## Step 11: Deployment

1. Archive your app in Xcode
2. Upload to App Store Connect
3. Submit for review
4. Monitor analytics and crash reports
5. Respond to user feedback

## Troubleshooting

### Common Issues

**Firebase not initializing**
- Check GoogleService-Info.plist is in project root
- Verify bundle ID matches Firebase project
- Check Firebase is added to target

**RevenueCat not working**
- Verify API key is correct
- Check products are configured in App Store Connect
- Ensure products are added to RevenueCat dashboard

**Superwall not showing**
- Verify API key is correct
- Check campaigns are active
- Verify RevenueCat integration

**Subscriptions not working**
- Use sandbox test accounts
- Check products are approved in App Store Connect
- Verify entitlement configuration in RevenueCat

## Support

For issues or questions:
- Email: support@aftersplit.com
- Documentation: See code comments in service files
- Firebase: https://firebase.google.com/docs
- RevenueCat: https://docs.revenuecat.com
- Superwall: https://docs.superwall.com
