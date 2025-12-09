//
//  FirebaseManager.swift
//  AfterSplit
//
//  Firebase initialization and configuration
//

import Foundation
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import FirebaseRemoteConfig

@MainActor
class FirebaseManager {
    static let shared = FirebaseManager()
    
    private var isConfigured = false
    
    private init() {}
    
    func configure() {
        guard !isConfigured else { return }
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Crashlytics
        if AppConfig.enableCrashlytics {
            configureCrashlytics()
        }
        
        // Configure Remote Config
        if AppConfig.enableRemoteConfig {
            configureRemoteConfig()
        }
        
        // Log app launch
        if AppConfig.enableAnalytics {
            Analytics.logEvent("app_launched", parameters: nil)
        }
        
        isConfigured = true
        print("✅ Firebase configured successfully")
    }
    
    private func configureCrashlytics() {
        // Crashlytics is automatically configured when FirebaseApp.configure() is called
        // Additional configuration can be added here if needed
    }
    
    private func configureRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        
        if AppConfig.isDebugMode {
            settings.minimumFetchInterval = 0 // Fetch immediately in debug
        } else {
            settings.minimumFetchInterval = 3600 // Fetch every hour in production
        }
        
        remoteConfig.configSettings = settings
        
        // Set default values
        remoteConfig.setDefaults([
            "paywall_trigger_after_onboarding": true as NSObject,
            "free_tier_photo_limit": 10 as NSObject,
            "free_tier_video_limit": 3 as NSObject,
            "enable_premium_filters": true as NSObject,
            "enable_premium_split_styles": true as NSObject
        ])
        
        // Fetch remote config
        remoteConfig.fetch { status, error in
            if status == .success {
                remoteConfig.activate { changed, error in
                    if let error = error {
                        print("❌ Remote Config activation error: \(error.localizedDescription)")
                    } else {
                        print("✅ Remote Config activated")
                    }
                }
            } else if let error = error {
                print("❌ Remote Config fetch error: \(error.localizedDescription)")
            }
        }
    }
    
    func setUserID(_ userID: String) {
        Analytics.setUserID(userID)
        Crashlytics.crashlytics().setUserID(userID)
    }
    
    func setUserProperty(name: String, value: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}
