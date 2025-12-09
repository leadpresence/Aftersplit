//
//  SuperwallManager.swift
//  AfterSplit
//
//  Superwall SDK integration and paywall management
//

import Foundation
import SuperwallKit

@MainActor
class SuperwallManager {
    static let shared = SuperwallManager()
    
    private var isConfigured = false
    
    private init() {}
    
    func configure(apiKey: String) {
        guard !isConfigured else { return }
        
        Superwall.configure(apiKey: apiKey)
        
        // Set up delegate for paywall events
        Superwall.shared.delegate = self
        
        isConfigured = true
        print("✅ Superwall configured successfully")
    }
    
    func register(entitlements: [String]) {
        Superwall.shared.register(entitlements: entitlements)
    }
    
    func presentPaywall(identifier: String? = nil) {
        if let identifier = identifier {
            Superwall.shared.register(identifier)
        }
        Superwall.shared.present()
    }
    
    func presentPaywall(forEvent event: String) {
        Superwall.shared.register(event)
    }
}

extension SuperwallManager: SuperwallDelegate {
    nonisolated func handleSuperwallEvent(_ eventInfo: SuperwallEventInfo) {
        Task { @MainActor in
            switch eventInfo.event {
            case .transactionStart:
                AnalyticsManager.shared.trackPaywallPurchaseAttempt(
                    productID: eventInfo.productId ?? "unknown"
                )
            case .transactionComplete:
                if let productId = eventInfo.productId {
                    AnalyticsManager.shared.trackSubscriptionPurchased(
                        productID: productId,
                        price: 0, // Price will be tracked by RevenueCat
                        currency: "USD"
                    )
                }
            case .transactionFail:
                if let error = eventInfo.error {
                    AnalyticsManager.shared.trackPaywallPurchaseError(
                        productID: eventInfo.productId ?? "unknown",
                        error: error.localizedDescription
                    )
                }
            case .paywallClose:
                AnalyticsManager.shared.trackPaywallDismissed(
                    trigger: eventInfo.event.description,
                    didPurchase: false
                )
            default:
                break
            }
        }
    }
}
