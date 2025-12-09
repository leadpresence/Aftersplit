# App Store Connect Setup Guide

This guide covers the App Store Connect configuration needed for AfterSplit subscriptions.

## Step 1: Create App in App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to **My Apps** > **+** > **New App**
3. Fill in app information:
   - Platform: iOS
   - Name: AfterSplit
   - Primary Language: English
   - Bundle ID: `leadpresence.AfterSplit`
   - SKU: `aftersplit-001`
   - User Access: Full Access

## Step 2: Create Subscription Group

1. In App Store Connect, go to your app
2. Navigate to **Features** > **In-App Purchases**
3. Click **+** to create a subscription group
4. Name: **AfterSplit Premium**
5. Reference Name: **AfterSplit Premium**
6. Click **Create**

## Step 3: Create Subscription Products

### Product 1: 7-Day Trial ($0.39)

1. In the subscription group, click **+** to add subscription
2. **Product Information**:
   - Type: Auto-Renewable Subscription
   - Subscription Group: AfterSplit Premium
   - Reference Name: 7-Day Trial
   - Product ID: `trial_7days_039`
   - Subscription Duration: 1 Week
   - Price: $0.39 USD

3. **Subscription Display Name**: "7-Day Trial"
4. **Description**: "Start with a 7-day trial for $0.39, then continue with monthly or yearly subscription"

5. **Review Information**:
   - Screenshot: Upload app screenshot showing trial offer
   - Review Notes: "7-day trial subscription for $0.39"

6. **Localization**: Add for all supported languages

### Product 2: Monthly Subscription ($3.99)

1. Click **+** to add another subscription
2. **Product Information**:
   - Type: Auto-Renewable Subscription
   - Subscription Group: AfterSplit Premium
   - Reference Name: Monthly
   - Product ID: `monthly_399`
   - Subscription Duration: 1 Month
   - Price: $3.99 USD

3. **Subscription Display Name**: "Monthly Premium"
4. **Description**: "Unlimited access to all premium features for $3.99 per month"

5. **Review Information**:
   - Screenshot: Upload app screenshot
   - Review Notes: "Monthly subscription for premium features"

### Product 3: Yearly Subscription ($29.99)

1. Click **+** to add another subscription
2. **Product Information**:
   - Type: Auto-Renewable Subscription
   - Subscription Group: AfterSplit Premium
   - Reference Name: Yearly
   - Product ID: `yearly_2999`
   - Subscription Duration: 1 Year
   - Price: $29.99 USD

3. **Subscription Display Name**: "Yearly Premium"
4. **Description**: "Best value! Get unlimited access to all premium features for $29.99 per year (save 37% compared to monthly)"

5. **Review Information**:
   - Screenshot: Upload app screenshot
   - Review Notes: "Yearly subscription for premium features"

## Step 4: Configure Subscription Group

1. In the subscription group, set the **Display Order**:
   - 1. Yearly ($29.99/year) - Best Value
   - 2. Monthly ($3.99/month)
   - 3. 7-Day Trial ($0.39)

2. Set **Subscription Duration** for each product

3. Configure **Introductory Offers**:
   - For Monthly and Yearly: Offer 7-day free trial
   - For 7-Day Trial: Set as introductory offer

## Step 5: App Information

### App Privacy

1. Go to **App Privacy** section
2. Answer privacy questions:
   - **Data Collection**: Yes
   - **Analytics Data**: Collected
     - Purpose: App Functionality, Analytics
     - Linked to User: No
     - Used for Tracking: Optional (with permission)
   - **Crash Data**: Collected
     - Purpose: App Functionality
     - Linked to User: No
     - Used for Tracking: No

3. **Privacy Policy URL**: `https://aftersplit.com/privacy`
4. **Privacy Choices**: Optional tracking with user permission

### App Information

1. **Category**: Photo & Video
2. **Age Rating**: 4+ (No objectionable content)
3. **Support URL**: `https://aftersplit.com/support`
4. **Marketing URL**: `https://aftersplit.com`

## Step 6: App Store Listing

### Description

```
AfterSplit - Dual Camera Capture

Capture stunning photos and videos using both front and back cameras simultaneously! Create unique split-screen compositions with professional filters and effects.

Features:
• Dual camera capture - front and back cameras at once
• Multiple split styles - choose from various layouts
• Premium filters - enhance your captures
• High-quality exports - up to 4K video
• Unlimited captures with Premium subscription

Start with a 7-day trial for just $0.39, then choose monthly ($3.99) or yearly ($29.99) subscription.

Download now and start creating amazing dual-camera content!
```

### Keywords

`camera,dual camera,split screen,photo,video,filter,premium,subscription`

### Promotional Text

```
New in this version:
• Improved camera performance
• New premium filters
• Enhanced video quality
• Bug fixes and stability improvements
```

## Step 7: Pricing and Availability

1. **Price**: Free (with in-app purchases)
2. **Availability**: All countries
3. **Pre-Order**: Not applicable

## Step 8: Version Information

1. **Version**: 1.2
2. **Build**: 2
3. **Copyright**: © 2025 AfterSplit
4. **What's New**:
   ```
   • New subscription options with 7-day trial
   • Premium features unlocked
   • Improved performance and stability
   • Bug fixes
   ```

## Step 9: App Review Information

1. **Contact Information**:
   - First Name: [Your Name]
   - Last Name: [Your Last Name]
   - Phone: [Your Phone]
   - Email: support@aftersplit.com

2. **Demo Account** (if needed):
   - Username: [Demo account]
   - Password: [Demo password]

3. **Notes**:
   ```
   Test Subscription:
   - Use sandbox test account for testing
   - All subscription products are configured
   - 7-day trial available for $0.39
   - Monthly and yearly options available
   ```

## Step 10: TestFlight Setup

1. Upload build via Xcode or Transporter
2. Add internal testers
3. Add external testers (if needed)
4. Test subscription flows with sandbox accounts

## Step 11: Submit for Review

1. Complete all required information
2. Upload screenshots (required sizes):
   - 6.7" iPhone (1290 x 2796)
   - 6.5" iPhone (1284 x 2778)
   - 5.5" iPhone (1242 x 2208)
   - iPad Pro 12.9" (2048 x 2732)

3. Add app preview video (optional but recommended)

4. Submit for review

## Important Notes

- **Product IDs must match exactly** with those in `AppConfig.swift`
- **Subscription group** must be created before products
- **Sandbox testing** is required before production
- **Review process** typically takes 24-48 hours
- **Subscription status** is managed by RevenueCat, not App Store Connect directly

## Troubleshooting

### Products Not Showing in App
- Verify product IDs match exactly
- Check products are approved in App Store Connect
- Ensure app is using correct bundle ID
- Test with sandbox account

### Subscription Not Working
- Verify RevenueCat is configured correctly
- Check entitlement mapping in RevenueCat dashboard
- Ensure products are in the same subscription group
- Test restore purchases functionality

### Review Rejection
- Common reasons: Missing subscription terms, unclear pricing, missing restore purchases
- Ensure all subscription information is clear
- Add restore purchases button in settings
- Include subscription terms in app

## Support

For App Store Connect issues:
- Apple Developer Support: https://developer.apple.com/support
- App Store Connect Help: Available in dashboard

For subscription issues:
- RevenueCat Support: https://docs.revenuecat.com
- Check RevenueCat dashboard for transaction logs
