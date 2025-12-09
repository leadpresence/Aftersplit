//
//  PayWallManager.swift
//  AfterSplit
//
//  Centralized paywall management and coordination
//

import Foundation
import Combine
import SuperwallKit
import RevenueCat

@MainActor
class PayWallManager: ObservableObject {
    static let shared = PayWallManager()
    
    @Published var isPresentingPaywall = false
    @Published var currentTrigger: PaywallTrigger?
    
    private let superwallManager = SuperwallManager.shared
    private let purchaseManager = PurchaseManager.shared
    private let subscriptionStateManager = SubscriptionStateManager.shared
    private let analyticsManager = AnalyticsManager.shared
    
    private init() {
        // Register entitlements with Superwall
        superwallManager.register(entitlements: [AppConfig.SubscriptionProducts.entitlementID])
    }
    
    // MARK: - Paywall Presentation
    
    func presentPaywall(trigger: PaywallTrigger? = nil) {
        guard !isPresentingPaywall else { return }
        
        currentTrigger = trigger
        isPresentingPaywall = true
        
        if let trigger = trigger {
            analyticsManager.trackPaywallViewed(trigger: trigger.description)
            superwallManager.presentPaywall(forEvent: trigger.description)
        } else {
            superwallManager.presentPaywall()
        }
    }
    
    func dismissPaywall(didPurchase: Bool = false) {
        isPresentingPaywall = false
        
        if let trigger = currentTrigger {
            analyticsManager.trackPaywallDismissed(
                trigger: trigger.description,
                didPurchase: didPurchase
            )
        }
        
        currentTrigger = nil
    }
    
    // MARK: - Purchase Handling
    
    func handlePurchase(package: Package) async throws {
        do {
            try await purchaseManager.purchase(package: package)
            dismissPaywall(didPurchase: true)
            
            // Refresh subscription status
            await subscriptionStateManager.refreshSubscriptionStatus()
        } catch {
            throw error
        }
    }
    
    func handleRestorePurchases() async throws {
        do {
            try await purchaseManager.restorePurchases()
            dismissPaywall(didPurchase: true)
        } catch {
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func getAvailableProducts() async throws -> [SubscriptionProduct] {
        return try await purchaseManager.getAvailableProducts()
    }
}
