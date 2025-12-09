//
//  SubscriptionError.swift
//  AfterSplit
//
//  Subscription-related error definitions
//

import Foundation

enum SubscriptionError: LocalizedError {
    case noOfferingsAvailable
    case productNotAvailable
    case purchaseCancelled
    case purchaseNotAllowed
    case purchaseInvalid
    case networkError
    case restoreFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .noOfferingsAvailable:
            return "No subscription offerings are currently available. Please try again later."
        case .productNotAvailable:
            return "This subscription product is not available at this time."
        case .purchaseCancelled:
            return "Purchase was cancelled."
        case .purchaseNotAllowed:
            return "Purchase is not allowed. Please check your device settings."
        case .purchaseInvalid:
            return "The purchase is invalid. Please contact support."
        case .networkError:
            return "Network error occurred. Please check your internet connection and try again."
        case .restoreFailed:
            return "Failed to restore purchases. Please try again or contact support."
        case .unknown(let message):
            return "An error occurred: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .restoreFailed:
            return "If you have an active subscription, please contact support with your receipt."
        default:
            return "Please try again or contact support if the problem persists."
        }
    }
}
