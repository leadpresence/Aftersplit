//
//  PaywallPresentationModifier.swift
//  AfterSplit
//
//  SwiftUI modifier for consistent paywall presentation
//

import SwiftUI

struct PaywallPresentationModifier: ViewModifier {
    @StateObject private var paywallTriggerManager = PaywallTriggerManager.shared
    @State private var showPaywall = false
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
            }
            .onChange(of: paywallTriggerManager.shouldShowPaywall) { oldValue, newValue in
                if newValue {
                    showPaywall = true
                }
            }
            .onChange(of: showPaywall) { oldValue, newValue in
                if !newValue {
                    paywallTriggerManager.shouldShowPaywall = false
                }
            }
    }
}

extension View {
    func paywallPresentation() -> some View {
        modifier(PaywallPresentationModifier())
    }
}
