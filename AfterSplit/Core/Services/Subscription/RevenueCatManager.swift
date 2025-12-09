//
//  RevenueCatManager.swift
//  AfterSplit
//
//  RevenueCat SDK integration and configuration
//

import Foundation
import RevenueCat

@MainActor
class RevenueCatManager {
    static let shared = RevenueCatManager()
    
    private var isConfigured = false
    
    private init() {}
    
    func configure(apiKey: String, appUserID: String? = nil) {
        guard !isConfigured else { return }
        
        Purchases.configure(
            with: Configuration.Builder(withAPIKey: apiKey)
                .with(appUserID: appUserID)
                .build()
        )
        
        // Set up delegate for subscription updates
        Purchases.shared.delegate = self
        
        isConfigured = true
        print("✅ RevenueCat configured successfully")
    }
    
    func setUserID(_ userID: String) {
        Purchases.shared.logIn(userID) { customerInfo, created, error in
            if let error = error {
                print("❌ RevenueCat login error: \(error.localizedDescription)")
            } else {
                print("✅ RevenueCat user ID set: \(userID)")
            }
        }
    }
    
    func getCustomerInfo() async throws -> CustomerInfo {
        return try await Purchases.shared.customerInfo()
    }
    
    func getOfferings() async throws -> Offerings {
        return try await Purchases.shared.offerings()
    }
    
    func purchase(package: Package) async throws -> (transaction: StoreTransaction?, customerInfo: CustomerInfo) {
        let (transaction, customerInfo, _, _) = try await Purchases.shared.purchase(package: package)
        return (transaction, customerInfo)
    }
    
    func restorePurchases() async throws -> CustomerInfo {
        return try await Purchases.shared.restorePurchases()
    }
}

extension RevenueCatManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            // Handle subscription status updates
            NotificationCenter.default.post(
                name: .subscriptionStatusUpdated,
                object: nil,
                userInfo: ["customerInfo": customerInfo]
            )
        }
    }
}

extension Notification.Name {
    static let subscriptionStatusUpdated = Notification.Name("subscriptionStatusUpdated")
}
