//
//  PurchaseManager.swift
//  AfterSplit
//
//  Purchase flow and transaction handling
//

import Foundation
import RevenueCat
import StoreKit

@MainActor
class PurchaseManager {
    static let shared = PurchaseManager()
    
    private let revenueCatManager = RevenueCatManager.shared
    private let analyticsManager = AnalyticsManager.shared
    private let crashlyticsManager = CrashlyticsManager.shared
    
    private init() {}
    
    // MARK: - Get Products
    
    func getAvailableProducts() async throws -> [SubscriptionProduct] {
        let offerings = try await revenueCatManager.getOfferings()
        
        guard let currentOffering = offerings.current else {
            throw SubscriptionError.noOfferingsAvailable
        }
        
        var products: [SubscriptionProduct] = []
        
        for package in currentOffering.availablePackages {
            if let product = mapPackageToSubscriptionProduct(package) {
                products.append(product)
            }
        }
        
        return products
    }
    
    // MARK: - Purchase
    
    func purchase(package: Package) async throws {
        analyticsManager.trackPaywallPurchaseAttempt(productID: package.storeProduct.productIdentifier)
        
        do {
            let (transaction, customerInfo) = try await revenueCatManager.purchase(package: package)
            
            // Track successful purchase
            if let price = package.storeProduct.price as? Decimal {
                let currencyCode = package.storeProduct.priceLocale?.currencyCode ?? "USD"
                analyticsManager.trackSubscriptionPurchased(
                    productID: package.storeProduct.productIdentifier,
                    price: price.doubleValue,
                    currency: currencyCode
                )
            }
            
            // Check if it's a trial
            let entitlement = customerInfo.entitlements.active[AppConfig.SubscriptionProducts.entitlementID]
            if entitlement?.periodType == .trial {
                analyticsManager.trackTrialStarted(productID: package.storeProduct.productIdentifier)
            }
            
            // Refresh subscription status
            await SubscriptionStateManager.shared.refreshSubscriptionStatus()
            
        } catch {
            let errorMessage = error.localizedDescription
            analyticsManager.trackPaywallPurchaseError(
                productID: package.storeProduct.productIdentifier,
                error: errorMessage
            )
            crashlyticsManager.logError(error, userInfo: ["context": "purchase", "productID": package.storeProduct.productIdentifier])
            throw mapRevenueCatError(error)
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async throws {
        do {
            let customerInfo = try await revenueCatManager.restorePurchases()
            analyticsManager.trackSubscriptionRestored()
            
            // Refresh subscription status
            await SubscriptionStateManager.shared.refreshSubscriptionStatus()
            
        } catch {
            crashlyticsManager.logError(error, userInfo: ["context": "restorePurchases"])
            throw mapRevenueCatError(error)
        }
    }
    
    // MARK: - Mapping
    
    private func mapPackageToSubscriptionProduct(_ package: Package) -> SubscriptionProduct? {
        let product = package.storeProduct
        
        // Determine period
        let period: SubscriptionProduct.SubscriptionPeriod
        if product.subscriptionPeriod?.unit == .month {
            period = .monthly
        } else if product.subscriptionPeriod?.unit == .year {
            period = .yearly
        } else {
            period = .monthly // Default
        }
        
        // Check if it's a trial
        let isTrial = product.introductoryPrice?.paymentMode == .freeTrial
        let trialDuration = product.introductoryPrice?.subscriptionPeriod.unit == .day
            ? TimeInterval(product.introductoryPrice!.subscriptionPeriod.value * 24 * 60 * 60)
            : nil
        
        return SubscriptionProduct(
            identifier: product.productIdentifier,
            displayName: product.localizedTitle,
            price: product.price as Decimal,
            priceLocale: product.priceLocale,
            period: period,
            isTrial: isTrial,
            trialDuration: trialDuration
        )
    }
    
    private func mapRevenueCatError(_ error: Error) -> SubscriptionError {
        // RevenueCat errors are typically ErrorCode enum cases
        // Check for common error cases
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("cancelled") || errorDescription.contains("cancel") {
            return .purchaseCancelled
        } else if errorDescription.contains("not available") || errorDescription.contains("unavailable") {
            return .productNotAvailable
        } else if errorDescription.contains("not allowed") || errorDescription.contains("forbidden") {
            return .purchaseNotAllowed
        } else if errorDescription.contains("invalid") {
            return .purchaseInvalid
        } else if errorDescription.contains("network") || errorDescription.contains("connection") {
            return .networkError
        } else {
            return .unknown(error.localizedDescription)
        }
    }
}
