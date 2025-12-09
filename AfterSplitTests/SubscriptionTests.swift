//
//  SubscriptionTests.swift
//  AfterSplitTests
//
//  Unit tests for subscription logic
//

import XCTest
@testable import AfterSplit

final class SubscriptionTests: XCTestCase {
    
    func testSubscriptionTierFreeByDefault() {
        // Given: A new subscription state manager
        let manager = SubscriptionStateManager.shared
        
        // When: Initial state
        // Then: Should be free tier
        XCTAssertEqual(manager.subscriptionTier, .free)
    }
    
    func testFeatureGateFreeTierLimitations() {
        // Given: Feature gate with free tier
        let featureGate = FeatureGate.shared
        
        // When: Checking premium features
        // Then: Should return false for free tier
        XCTAssertFalse(featureGate.isFeatureAvailable(.premiumFilters))
        XCTAssertFalse(featureGate.isFeatureAvailable(.premiumSplitStyles))
        XCTAssertFalse(featureGate.isFeatureAvailable(.noWatermark))
    }
    
    func testPaywallTriggerManagerUsageTracking() {
        // Given: Paywall trigger manager
        let manager = PaywallTriggerManager.shared
        
        // When: Resetting daily counts
        manager.resetDailyCounts()
        
        // Then: Counts should be zero
        XCTAssertEqual(manager.photosCapturedToday, 0)
        XCTAssertEqual(manager.videosRecordedToday, 0)
    }
    
    func testAppConfigProductIdentifiers() {
        // Then: Product identifiers should match expected values
        XCTAssertEqual(AppConfig.SubscriptionProducts.trial7Days, "trial_7days_039")
        XCTAssertEqual(AppConfig.SubscriptionProducts.monthly, "monthly_399")
        XCTAssertEqual(AppConfig.SubscriptionProducts.yearly, "yearly_2999")
        XCTAssertEqual(AppConfig.SubscriptionProducts.entitlementID, "premium")
    }
    
    func testFreeTierLimits() {
        // Then: Free tier limits should be set
        XCTAssertGreaterThan(AppConfig.FreeTierLimits.maxPhotosPerDay, 0)
        XCTAssertGreaterThan(AppConfig.FreeTierLimits.maxVideosPerDay, 0)
        XCTAssertGreaterThan(AppConfig.FreeTierLimits.maxVideoDuration, 0)
    }
}
