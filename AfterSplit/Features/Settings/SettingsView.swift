//
//  SettingsView.swift
//  AfterSplit
//
//  Settings and account management view
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var subscriptionStateManager = SubscriptionStateManager.shared
    @StateObject private var paywallManager = PayWallManager.shared
    @State private var showPaywall = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
    var body: some View {
        NavigationView {
            List {
                // Subscription Section
                Section("Subscription") {
                    if subscriptionStateManager.isLoading {
                        HStack {
                            ProgressView()
                            Text("Loading subscription status...")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        subscriptionStatusView
                    }
                    
                    if subscriptionStateManager.subscriptionTier == .free {
                        Button(action: {
                            showPaywall = true
                            paywallManager.presentPaywall()
                        }) {
                            HStack {
                                Text("Upgrade to Premium")
                                Spacer()
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    
                    Button("Restore Purchases") {
                        restorePurchases()
                    }
                    
                    if subscriptionStateManager.subscriptionTier == .premium,
                       let subscriptionInfo = subscriptionStateManager.subscriptionInfo {
                        Button("Manage Subscription") {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                Task {
                                    try? await AppStore.sync()
                                    if let subscription = subscriptionInfo.productIdentifier {
                                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                            await UIApplication.shared.open(url)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Account Section
                Section("Account") {
                    HStack {
                        Text("Subscription Status")
                        Spacer()
                        Text(subscriptionStateManager.subscriptionTier.displayName)
                            .foregroundColor(subscriptionStateManager.subscriptionTier == .premium ? .green : .secondary)
                    }
                    
                    if let subscriptionInfo = subscriptionStateManager.subscriptionInfo,
                       subscriptionInfo.isActive {
                        if let expirationDate = subscriptionInfo.expirationDate {
                            HStack {
                                Text("Expires")
                                Spacer()
                                Text(expirationDate, style: .date)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if subscriptionInfo.isTrial {
                            HStack {
                                Text("Trial Period")
                                Spacer()
                                Text("Active")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                // Support Section
                Section("Support") {
                    Link("Contact Support", destination: URL(string: "mailto:support@aftersplit.com")!)
                    Link("Privacy Policy", destination: URL(string: "https://aftersplit.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://aftersplit.com/terms")!)
                }
                
                // App Info Section
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
            }
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
        }
    }
    
    private var subscriptionStatusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Status")
                Spacer()
                if subscriptionStateManager.subscriptionTier == .premium {
                    Label("Premium", systemImage: "checkmark.seal.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Free", systemImage: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            if subscriptionStateManager.subscriptionTier == .premium,
               let subscriptionInfo = subscriptionStateManager.subscriptionInfo {
                if subscriptionInfo.isTrial {
                    Text("You're currently on a free trial")
                        .font(.caption)
                        .foregroundColor(.blue)
                } else if let expirationDate = subscriptionInfo.expirationDate {
                    Text("Renews on \(expirationDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Upgrade to unlock all features")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func restorePurchases() {
        Task {
            do {
                try await paywallManager.handleRestorePurchases()
                await MainActor.run {
                    restoreMessage = "Purchases restored successfully!"
                    showRestoreAlert = true
                }
            } catch {
                await MainActor.run {
                    restoreMessage = "Failed to restore purchases: \(error.localizedDescription)"
                    showRestoreAlert = true
                }
            }
        }
    }
}
