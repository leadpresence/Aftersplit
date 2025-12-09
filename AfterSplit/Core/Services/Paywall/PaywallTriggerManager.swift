//
//  PaywallTriggerManager.swift
//  AfterSplit
//
//  Manages paywall trigger points and conditions
//

import Foundation
import Combine

@MainActor
class PaywallTriggerManager: ObservableObject {
    static let shared = PaywallTriggerManager()
    
    @Published var shouldShowPaywall = false
    @Published var triggerReason: PaywallTrigger?
    
    private let subscriptionStateManager = SubscriptionStateManager.shared
    private let remoteConfigManager = RemoteConfigManager.shared
    private let analyticsManager = AnalyticsManager.shared
    
    // Usage tracking
    @Published private(set) var photosCapturedToday = 0
    @Published private(set) var videosRecordedToday = 0
    
    private let userDefaults = UserDefaults.standard
    private let photosKey = "photos_captured_today"
    private let videosKey = "videos_recorded_today"
    private let lastResetDateKey = "last_usage_reset_date"
    
    private init() {
        loadUsageCounts()
        resetCountsIfNeeded()
    }
    
    // MARK: - Trigger Checks
    
    func checkTriggerAfterOnboarding() {
        guard !hasActiveSubscription() else { return }
        guard remoteConfigManager.shouldShowPaywallAfterOnboarding() else { return }
        
        triggerPaywall(reason: .afterOnboarding)
    }
    
    func checkTriggerAfterPhotoCapture() {
        guard !hasActiveSubscription() else { return }
        
        photosCapturedToday += 1
        saveUsageCounts()
        
        let limit = remoteConfigManager.getPaywallTriggerPhotoLimit()
        if photosCapturedToday >= limit {
            triggerPaywall(reason: .photoLimitReached)
            analyticsManager.trackFreeTierLimitReached(limitType: "photos")
        }
    }
    
    func checkTriggerAfterVideoRecording() {
        guard !hasActiveSubscription() else { return }
        
        videosRecordedToday += 1
        saveUsageCounts()
        
        let limit = remoteConfigManager.getPaywallTriggerVideoLimit()
        if videosRecordedToday >= limit {
            triggerPaywall(reason: .videoLimitReached)
            analyticsManager.trackFreeTierLimitReached(limitType: "videos")
        }
    }
    
    func checkTriggerForPremiumFeature(_ feature: PremiumFeature) {
        guard !hasActiveSubscription() else { return }
        
        triggerPaywall(reason: .premiumFeatureAccess(feature))
        analyticsManager.trackUpgradePromptShown(trigger: feature.description)
    }
    
    // MARK: - Usage Limits
    
    func canCapturePhoto() -> Bool {
        if hasActiveSubscription() {
            return true
        }
        
        let limit = remoteConfigManager.getFreeTierPhotoLimit()
        return photosCapturedToday < limit
    }
    
    func canRecordVideo() -> Bool {
        if hasActiveSubscription() {
            return true
        }
        
        let limit = remoteConfigManager.getFreeTierVideoLimit()
        return videosRecordedToday < limit
    }
    
    func getRemainingPhotos() -> Int {
        if hasActiveSubscription() {
            return Int.max
        }
        
        let limit = remoteConfigManager.getFreeTierPhotoLimit()
        return max(0, limit - photosCapturedToday)
    }
    
    func getRemainingVideos() -> Int {
        if hasActiveSubscription() {
            return Int.max
        }
        
        let limit = remoteConfigManager.getFreeTierVideoLimit()
        return max(0, limit - videosRecordedToday)
    }
    
    // MARK: - Private Helpers
    
    private func hasActiveSubscription() -> Bool {
        return subscriptionStateManager.subscriptionTier == .premium
    }
    
    private func triggerPaywall(reason: PaywallTrigger) {
        triggerReason = reason
        shouldShowPaywall = true
        analyticsManager.trackPaywallViewed(trigger: reason.description)
    }
    
    private func loadUsageCounts() {
        photosCapturedToday = userDefaults.integer(forKey: photosKey)
        videosRecordedToday = userDefaults.integer(forKey: videosKey)
    }
    
    private func saveUsageCounts() {
        userDefaults.set(photosCapturedToday, forKey: photosKey)
        userDefaults.set(videosRecordedToday, forKey: videosKey)
    }
    
    private func resetCountsIfNeeded() {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastResetDate = userDefaults.object(forKey: lastResetDateKey) as? Date {
            if !calendar.isDate(lastResetDate, inSameDayAs: today) {
                photosCapturedToday = 0
                videosRecordedToday = 0
                saveUsageCounts()
                userDefaults.set(today, forKey: lastResetDateKey)
            }
        } else {
            userDefaults.set(today, forKey: lastResetDateKey)
        }
    }
    
    func resetDailyCounts() {
        photosCapturedToday = 0
        videosRecordedToday = 0
        saveUsageCounts()
        userDefaults.set(Date(), forKey: lastResetDateKey)
    }
}

enum PaywallTrigger {
    case afterOnboarding
    case photoLimitReached
    case videoLimitReached
    case premiumFeatureAccess(PremiumFeature)
    
    var description: String {
        switch self {
        case .afterOnboarding:
            return "after_onboarding"
        case .photoLimitReached:
            return "photo_limit_reached"
        case .videoLimitReached:
            return "video_limit_reached"
        case .premiumFeatureAccess(let feature):
            return "premium_feature_\(feature.description)"
        }
    }
}

extension PremiumFeature {
    var description: String {
        switch self {
        case .unlimitedPhotos: return "unlimited_photos"
        case .unlimitedVideos: return "unlimited_videos"
        case .premiumFilters: return "premium_filters"
        case .premiumSplitStyles: return "premium_split_styles"
        case .noWatermark: return "no_watermark"
        case .highQualityExport: return "high_quality_export"
        case .cloudBackup: return "cloud_backup"
        case .advancedEditing: return "advanced_editing"
        }
    }
}
