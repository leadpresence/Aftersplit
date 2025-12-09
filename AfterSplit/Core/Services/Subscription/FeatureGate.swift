//
//  FeatureGate.swift
//  AfterSplit
//
//  Feature availability checking and premium access control
//

import Foundation
import Combine

@MainActor
class FeatureGate: ObservableObject {
    static let shared = FeatureGate()
    
    private let subscriptionStateManager = SubscriptionStateManager.shared
    private let paywallTriggerManager = PaywallTriggerManager.shared
    private let remoteConfigManager = RemoteConfigManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Observe subscription changes
        subscriptionStateManager.$subscriptionTier
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Feature Availability
    
    func isFeatureAvailable(_ feature: PremiumFeature) -> Bool {
        // Premium users have access to all features
        if subscriptionStateManager.subscriptionTier == .premium {
            return true
        }
        
        // Check feature-specific availability
        switch feature {
        case .unlimitedPhotos:
            return subscriptionStateManager.subscriptionTier == .premium
            
        case .unlimitedVideos:
            return subscriptionStateManager.subscriptionTier == .premium
            
        case .premiumFilters:
            return remoteConfigManager.arePremiumFiltersEnabled() && 
                   subscriptionStateManager.subscriptionTier == .premium
            
        case .premiumSplitStyles:
            return remoteConfigManager.arePremiumSplitStylesEnabled() && 
                   subscriptionStateManager.subscriptionTier == .premium
            
        case .noWatermark:
            return subscriptionStateManager.subscriptionTier == .premium
            
        case .highQualityExport:
            return subscriptionStateManager.subscriptionTier == .premium
            
        case .cloudBackup:
            return subscriptionStateManager.subscriptionTier == .premium
            
        case .advancedEditing:
            return subscriptionStateManager.subscriptionTier == .premium
        }
    }
    
    func checkFeatureAccess(_ feature: PremiumFeature) -> FeatureAccessResult {
        if isFeatureAvailable(feature) {
            return .allowed
        } else {
            // Trigger paywall if feature is not available
            paywallTriggerManager.checkTriggerForPremiumFeature(feature)
            return .requiresPremium
        }
    }
    
    // MARK: - Free Tier Limitations
    
    func canCapturePhoto() -> Bool {
        if subscriptionStateManager.subscriptionTier == .premium {
            return true
        }
        return paywallTriggerManager.canCapturePhoto()
    }
    
    func canRecordVideo() -> Bool {
        if subscriptionStateManager.subscriptionTier == .premium {
            return true
        }
        return paywallTriggerManager.canRecordVideo()
    }
    
    func shouldShowWatermark() -> Bool {
        if subscriptionStateManager.subscriptionTier == .premium {
            return false
        }
        return AppConfig.FreeTierLimits.enableWatermark
    }
    
    func getMaxVideoQuality() -> String {
        if subscriptionStateManager.subscriptionTier == .premium {
            return "4K"
        }
        return AppConfig.FreeTierLimits.maxVideoQuality
    }
    
    func getMaxVideoDuration() -> TimeInterval {
        if subscriptionStateManager.subscriptionTier == .premium {
            return .infinity
        }
        return AppConfig.FreeTierLimits.maxVideoDuration
    }
    
    // MARK: - Premium Status
    
    var isPremium: Bool {
        return subscriptionStateManager.subscriptionTier == .premium
    }
    
    var subscriptionTier: SubscriptionTier {
        return subscriptionStateManager.subscriptionTier
    }
}

enum FeatureAccessResult {
    case allowed
    case requiresPremium
}
