//
//  RemoteConfigManager.swift
//  AfterSplit
//
//  Firebase Remote Config management
//

import Foundation
import FirebaseRemoteConfig

@MainActor
class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    private init() {
        configure()
    }
    
    private func configure() {
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
            "enable_premium_split_styles": true as NSObject,
            "paywall_trigger_photo_limit": 5 as NSObject,
            "paywall_trigger_video_limit": 2 as NSObject,
            "trial_duration_days": 7 as NSObject
        ])
    }
    
    // MARK: - Fetching
    
    func fetch(completion: ((Bool, Error?) -> Void)? = nil) {
        remoteConfig.fetch { [weak self] status, error in
            guard let self = self else { return }
            
            if status == .success {
                self.remoteConfig.activate { changed, error in
                    if let error = error {
                        completion?(false, error)
                    } else {
                        completion?(true, nil)
                    }
                }
            } else {
                completion?(false, error)
            }
        }
    }
    
    // MARK: - Feature Flags
    
    func shouldShowPaywallAfterOnboarding() -> Bool {
        return remoteConfig.configValue(forKey: "paywall_trigger_after_onboarding").boolValue
    }
    
    func getFreeTierPhotoLimit() -> Int {
        return Int(truncating: remoteConfig.configValue(forKey: "free_tier_photo_limit").numberValue)
    }
    
    func getFreeTierVideoLimit() -> Int {
        return Int(truncating: remoteConfig.configValue(forKey: "free_tier_video_limit").numberValue)
    }
    
    func getPaywallTriggerPhotoLimit() -> Int {
        return Int(truncating: remoteConfig.configValue(forKey: "paywall_trigger_photo_limit").numberValue)
    }
    
    func getPaywallTriggerVideoLimit() -> Int {
        return Int(truncating: remoteConfig.configValue(forKey: "paywall_trigger_video_limit").numberValue)
    }
    
    func arePremiumFiltersEnabled() -> Bool {
        return remoteConfig.configValue(forKey: "enable_premium_filters").boolValue
    }
    
    func arePremiumSplitStylesEnabled() -> Bool {
        return remoteConfig.configValue(forKey: "enable_premium_split_styles").boolValue
    }
    
    func getTrialDurationDays() -> Int {
        return Int(truncating: remoteConfig.configValue(forKey: "trial_duration_days").numberValue)
    }
    
    // MARK: - Generic Value Access
    
    func getString(forKey key: String) -> String? {
        return remoteConfig.configValue(forKey: key).stringValue
    }
    
    func getBool(forKey key: String) -> Bool {
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    func getInt(forKey key: String) -> Int {
        return Int(truncating: remoteConfig.configValue(forKey: key).numberValue)
    }
    
    func getDouble(forKey key: String) -> Double {
        return remoteConfig.configValue(forKey: key).numberValue.doubleValue
    }
}
