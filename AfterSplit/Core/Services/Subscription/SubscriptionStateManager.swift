//
//  SubscriptionStateManager.swift
//  AfterSplit
//
//  Observable subscription state management
//

import Foundation
import Combine
import RevenueCat

@MainActor
class SubscriptionStateManager: ObservableObject {
    static let shared = SubscriptionStateManager()
    
    @Published var subscriptionInfo: SubscriptionInfo?
    @Published var subscriptionTier: SubscriptionTier = .free
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let revenueCatManager = RevenueCatManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupObservers()
        Task {
            await refreshSubscriptionStatus()
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .subscriptionStatusUpdated)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.refreshSubscriptionStatus()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Subscription Status
    
    func refreshSubscriptionStatus() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let customerInfo = try await revenueCatManager.getCustomerInfo()
            subscriptionInfo = mapCustomerInfoToSubscriptionInfo(customerInfo)
            subscriptionTier = determineSubscriptionTier(from: customerInfo)
        } catch {
            errorMessage = error.localizedDescription
            CrashlyticsManager.shared.logError(error, userInfo: ["context": "refreshSubscriptionStatus"])
        }
        
        isLoading = false
    }
    
    func hasActiveSubscription() async -> Bool {
        do {
            let customerInfo = try await revenueCatManager.getCustomerInfo()
            return customerInfo.entitlements.active[AppConfig.SubscriptionProducts.entitlementID] != nil
        } catch {
            return false
        }
    }
    
    func isInTrial() async -> Bool {
        guard let subscriptionInfo = subscriptionInfo else {
            return false
        }
        return subscriptionInfo.isTrial
    }
    
    // MARK: - Mapping
    
    private func mapCustomerInfoToSubscriptionInfo(_ customerInfo: CustomerInfo) -> SubscriptionInfo {
        let entitlement = customerInfo.entitlements.active[AppConfig.SubscriptionProducts.entitlementID]
        
        let isActive = entitlement != nil
        let isTrial = entitlement?.periodType == .trial
        let expirationDate = entitlement?.expirationDate
        let productIdentifier = entitlement?.productIdentifier
        let willRenew = entitlement?.willRenew ?? false
        let isInGracePeriod = entitlement?.isActive == true && entitlement?.willRenew == false
        let isInBillingRetryPeriod = false // RevenueCat handles this internally
        
        return SubscriptionInfo(
            isActive: isActive,
            isTrial: isTrial,
            expirationDate: expirationDate,
            productIdentifier: productIdentifier,
            willRenew: willRenew,
            isInGracePeriod: isInGracePeriod,
            isInBillingRetryPeriod: isInBillingRetryPeriod
        )
    }
    
    private func determineSubscriptionTier(from customerInfo: CustomerInfo) -> SubscriptionTier {
        let hasEntitlement = customerInfo.entitlements.active[AppConfig.SubscriptionProducts.entitlementID] != nil
        return hasEntitlement ? .premium : .free
    }
}
