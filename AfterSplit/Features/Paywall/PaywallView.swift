//
//  PaywallView.swift
//  AfterSplit
//
//  Paywall UI using Superwall integration
//

import SwiftUI
import SuperwallKit
import RevenueCat

struct PaywallView: View {
    @StateObject private var paywallManager = PayWallManager.shared
    @StateObject private var subscriptionStateManager = SubscriptionStateManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    @State private var availableProducts: [SubscriptionProduct] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Superwall paywall will be presented automatically
            // This view serves as a container and fallback
            
            if isLoading {
                ProgressView("Loading subscriptions...")
            } else if !availableProducts.isEmpty {
                CustomPaywallView(
                    products: availableProducts,
                    onPurchase: handlePurchase,
                    onRestore: handleRestore,
                    onDismiss: {
                        isPresented = false
                        paywallManager.dismissPaywall()
                    }
                )
            } else {
                VStack(spacing: 20) {
                    Text("Upgrade to Premium")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Unlock all features and remove limitations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Close") {
                        isPresented = false
                        paywallManager.dismissPaywall()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            
            if let errorMessage = errorMessage {
                VStack {
                    Spacer()
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            loadProducts()
        }
        .onChange(of: subscriptionStateManager.subscriptionTier) { oldValue, newValue in
            if newValue == .premium {
                isPresented = false
                paywallManager.dismissPaywall(didPurchase: true)
            }
        }
    }
    
    private func loadProducts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let products = try await paywallManager.getAvailableProducts()
                await MainActor.run {
                    availableProducts = products
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func handlePurchase(_ product: SubscriptionProduct) {
        Task {
            do {
                // Get the package from RevenueCat
                let offerings = try await RevenueCatManager.shared.getOfferings()
                if let package = offerings.current?.availablePackages.first(where: { $0.storeProduct.productIdentifier == product.identifier }) {
                    try await paywallManager.handlePurchase(package: package)
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleRestore() {
        Task {
            do {
                try await paywallManager.handleRestorePurchases()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct CustomPaywallView: View {
    let products: [SubscriptionProduct]
    let onPurchase: (SubscriptionProduct) -> Void
    let onRestore: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Unlock Premium")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Get unlimited access to all features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Features list
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "camera.fill", text: "Unlimited photos & videos")
                    FeatureRow(icon: "sparkles", text: "Premium filters & effects")
                    FeatureRow(icon: "rectangle.split.2x1", text: "Advanced split styles")
                    FeatureRow(icon: "checkmark.seal.fill", text: "No watermarks")
                    FeatureRow(icon: "4k.tv", text: "4K video quality")
                }
                .padding()
                
                // Products
                VStack(spacing: 12) {
                    ForEach(products, id: \.identifier) { product in
                        ProductCard(product: product) {
                            onPurchase(product)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Restore purchases
                Button("Restore Purchases") {
                    onRestore()
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 8)
                
                // Terms
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}

struct ProductCard: View {
    let product: SubscriptionProduct
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    
                    if product.isTrial {
                        Text("7-day trial, then \(formatPrice(product.price))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(formatPrice(product.price)) per \(product.period.displayName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale ?? Locale.current
        return formatter.string(from: price as NSDecimalNumber) ?? "$\(price)"
    }
}
