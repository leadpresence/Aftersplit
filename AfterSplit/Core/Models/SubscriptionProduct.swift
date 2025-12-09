//
//  SubscriptionProduct.swift
//  AfterSplit
//
//  Subscription product definitions and models
//

import Foundation

struct SubscriptionProduct {
    let identifier: String
    let displayName: String
    let price: Decimal
    let priceLocale: Locale?
    let period: SubscriptionPeriod
    let isTrial: Bool
    let trialDuration: TimeInterval?
    
    enum SubscriptionPeriod {
        case weekly
        case monthly
        case yearly
        
        var displayName: String {
            switch self {
            case .weekly: return "week"
            case .monthly: return "month"
            case .yearly: return "year"
            }
        }
    }
}

struct SubscriptionInfo {
    let isActive: Bool
    let isTrial: Bool
    let expirationDate: Date?
    let productIdentifier: String?
    let willRenew: Bool
    let isInGracePeriod: Bool
    let isInBillingRetryPeriod: Bool
}

enum SubscriptionTier {
    case free
    case premium
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium"
        }
    }
}
