//
//  PremiumBadge.swift
//  AfterSplit
//
//  Premium feature indicators and badges
//

import SwiftUI

struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.caption2)
            Text("PRO")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(.yellow)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.black.opacity(0.7))
        .cornerRadius(4)
    }
}

struct PremiumLockIcon: View {
    var size: CGFloat = 16
    
    var body: some View {
        Image(systemName: "lock.fill")
            .font(.system(size: size))
            .foregroundColor(.secondary)
    }
}

struct PremiumFeatureIndicator: View {
    let feature: PremiumFeature
    @StateObject private var featureGate = FeatureGate.shared
    
    var body: some View {
        if !featureGate.isFeatureAvailable(feature) {
            PremiumLockIcon()
        }
    }
}

struct PremiumUpgradePrompt: View {
    let message: String
    let onUpgrade: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button("Upgrade to Premium") {
                onUpgrade()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}
