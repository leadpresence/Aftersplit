//
//  AnalyticsManager.swift
//  AfterSplit
//
//  Centralized analytics event tracking
//

import Foundation
import FirebaseAnalytics

@MainActor
class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - App Lifecycle Events
    
    func trackAppLaunch() {
        logEvent("app_launched", parameters: nil)
    }
    
    func trackAppBackgrounded() {
        logEvent("app_backgrounded", parameters: nil)
    }
    
    func trackAppForegrounded() {
        logEvent("app_foregrounded", parameters: nil)
    }
    
    // MARK: - Camera Events
    
    func trackCameraSessionStarted() {
        logEvent("camera_session_started", parameters: nil)
    }
    
    func trackCameraSessionEnded(duration: TimeInterval) {
        logEvent("camera_session_ended", parameters: [
            "duration_seconds": duration
        ])
    }
    
    func trackPhotoCaptured(filter: String, splitStyle: String) {
        logEvent("photo_captured", parameters: [
            "filter": filter,
            "split_style": splitStyle
        ])
    }
    
    func trackVideoRecorded(duration: TimeInterval, filter: String, splitStyle: String) {
        logEvent("video_recorded", parameters: [
            "duration_seconds": duration,
            "filter": filter,
            "split_style": splitStyle
        ])
    }
    
    // MARK: - Feature Usage
    
    func trackFilterApplied(filterName: String, isPremium: Bool) {
        logEvent("filter_applied", parameters: [
            "filter_name": filterName,
            "is_premium": isPremium
        ])
    }
    
    func trackSplitStyleChanged(styleName: String, isPremium: Bool) {
        logEvent("split_style_changed", parameters: [
            "style_name": styleName,
            "is_premium": isPremium
        ])
    }
    
    // MARK: - Subscription Events
    
    func trackPaywallViewed(trigger: String) {
        logEvent("paywall_viewed", parameters: [
            "trigger": trigger
        ])
    }
    
    func trackTrialStarted(productID: String) {
        logEvent("trial_started", parameters: [
            "product_id": productID
        ])
    }
    
    func trackSubscriptionPurchased(productID: String, price: Double, currency: String) {
        logEvent("subscription_purchased", parameters: [
            "product_id": productID,
            "price": price,
            "currency": currency
        ])
    }
    
    func trackSubscriptionRestored() {
        logEvent("subscription_restored", parameters: nil)
    }
    
    func trackSubscriptionCancelled() {
        logEvent("subscription_cancelled", parameters: nil)
    }
    
    func trackSubscriptionExpired() {
        logEvent("subscription_expired", parameters: nil)
    }
    
    // MARK: - Paywall Events
    
    func trackPaywallDismissed(trigger: String, didPurchase: Bool) {
        logEvent("paywall_dismissed", parameters: [
            "trigger": trigger,
            "did_purchase": didPurchase
        ])
    }
    
    func trackPaywallPurchaseAttempt(productID: String) {
        logEvent("paywall_purchase_attempt", parameters: [
            "product_id": productID
        ])
    }
    
    func trackPaywallPurchaseError(productID: String, error: String) {
        logEvent("paywall_purchase_error", parameters: [
            "product_id": productID,
            "error": error
        ])
    }
    
    // MARK: - Free Tier Limitations
    
    func trackFreeTierLimitReached(limitType: String) {
        logEvent("free_tier_limit_reached", parameters: [
            "limit_type": limitType
        ])
    }
    
    func trackUpgradePromptShown(trigger: String) {
        logEvent("upgrade_prompt_shown", parameters: [
            "trigger": trigger
        ])
    }
    
    // MARK: - Gallery Events
    
    func trackMediaViewed(mediaType: String) {
        logEvent("media_viewed", parameters: [
            "media_type": mediaType
        ])
    }
    
    func trackMediaShared(mediaType: String) {
        logEvent("media_shared", parameters: [
            "media_type": mediaType
        ])
    }
    
    func trackMediaDeleted(mediaType: String) {
        logEvent("media_deleted", parameters: [
            "media_type": mediaType
        ])
    }
    
    // MARK: - Error Events
    
    func trackError(error: Error, context: String) {
        logEvent("error_occurred", parameters: [
            "error_description": error.localizedDescription,
            "context": context
        ])
    }
    
    // MARK: - Private Helpers
    
    private func logEvent(_ name: String, parameters: [String: Any]?) {
        guard AppConfig.enableAnalytics else { return }
        
        Analytics.logEvent(name, parameters: parameters)
        
        if AppConfig.isDebugMode {
            print("📊 Analytics: \(name) - \(parameters ?? [:])")
        }
    }
}
