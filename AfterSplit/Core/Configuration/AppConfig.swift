//
//  AppConfig.swift
//  AfterSplit
//
//  Production configuration and environment management
//

import Foundation

enum Environment {
    case development
    case production
}

struct AppConfig {
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    // Firebase Configuration
    static var firebaseEnabled: Bool {
        return true
    }
    
    // RevenueCat Configuration
    static var revenueCatAPIKey: String {
        // TODO: Replace with your actual RevenueCat API key
        // Get from: https://app.revenuecat.com
        return "YOUR_REVENUECAT_API_KEY"
    }
    
    // Superwall Configuration
    static var superwallAPIKey: String {
        // TODO: Replace with your actual Superwall API key
        // Get from: https://superwall.com/dashboard
        return "YOUR_SUPERWALL_API_KEY"
    }
    
    // Subscription Product Identifiers
    struct SubscriptionProducts {
        static let trial7Days = "trial_7days_039"
        static let monthly = "monthly_399"
        static let yearly = "yearly_2999"
        
        static let entitlementID = "premium"
    }
    
    // Feature Flags
    static var enableAnalytics: Bool {
        return true
    }
    
    static var enableCrashlytics: Bool {
        return true
    }
    
    static var enableRemoteConfig: Bool {
        return true
    }
    
    // Free Tier Limitations
    struct FreeTierLimits {
        static let maxPhotosPerDay = 10
        static let maxVideosPerDay = 3
        static let maxVideoDuration: TimeInterval = 60.0 // 60 seconds
        static let enableWatermark = true
        static let maxVideoQuality = "720p"
    }
    
    // Debug Settings
    static var isDebugMode: Bool {
        return current == .development
    }
    
    static var logLevel: LogLevel {
        return isDebugMode ? .debug : .error
    }
}

enum LogLevel {
    case debug
    case info
    case warning
    case error
}
