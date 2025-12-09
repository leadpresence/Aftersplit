//
//  SubscriptionServiceProtocol.swift
//  AfterSplit
//
//  Protocol for subscription service implementation
//

import Foundation
import Combine

protocol SubscriptionServiceProtocol {
    /// Current subscription status
    var subscriptionStatus: CurrentValueSubject<SubscriptionInfo?, Never> { get }
    
    /// Current subscription tier
    var subscriptionTier: CurrentValueSubject<SubscriptionTier, Never> { get }
    
    /// Check if user has active subscription
    func hasActiveSubscription() async -> Bool
    
    /// Check if user is in trial period
    func isInTrial() async -> Bool
    
    /// Get available subscription products
    func getProducts() async throws -> [SubscriptionProduct]
    
    /// Purchase a subscription product
    func purchase(product: SubscriptionProduct) async throws
    
    /// Restore previous purchases
    func restorePurchases() async throws
    
    /// Get current subscription information
    func getSubscriptionInfo() async -> SubscriptionInfo?
    
    /// Check if a specific feature is available
    func isFeatureAvailable(_ feature: PremiumFeature) -> Bool
}

enum PremiumFeature {
    case unlimitedPhotos
    case unlimitedVideos
    case premiumFilters
    case premiumSplitStyles
    case noWatermark
    case highQualityExport
    case cloudBackup
    case advancedEditing
}
