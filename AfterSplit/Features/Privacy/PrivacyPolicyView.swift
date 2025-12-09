//
//  PrivacyPolicyView.swift
//  AfterSplit
//
//  Privacy Policy view
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Last Updated: \(Date(), style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                SectionView(title: "Information We Collect") {
                    Text("We collect information that you provide directly to us, including:")
                    BulletPoint("Account information (if you create an account)")
                    BulletPoint("Usage data and analytics")
                    BulletPoint("Device information")
                    BulletPoint("Camera and photo library access (with your permission)")
                }
                
                SectionView(title: "How We Use Your Information") {
                    Text("We use the information we collect to:")
                    BulletPoint("Provide and improve our services")
                    BulletPoint("Process transactions and manage subscriptions")
                    BulletPoint("Send you technical notices and support messages")
                    BulletPoint("Monitor and analyze usage patterns")
                }
                
                SectionView(title: "Data Storage") {
                    Text("Your photos and videos are stored locally on your device. We do not upload your media to our servers unless you explicitly choose to use cloud backup features.")
                }
                
                SectionView(title: "Third-Party Services") {
                    Text("We use third-party services that may collect information:")
                    BulletPoint("Firebase Analytics - for app usage analytics")
                    BulletPoint("RevenueCat - for subscription management")
                    BulletPoint("Superwall - for paywall presentation")
                }
                
                SectionView(title: "Your Rights") {
                    Text("You have the right to:")
                    BulletPoint("Access your personal data")
                    BulletPoint("Request deletion of your data")
                    BulletPoint("Opt-out of analytics")
                    BulletPoint("Cancel your subscription at any time")
                }
                
                SectionView(title: "Contact Us") {
                    Text("If you have questions about this Privacy Policy, please contact us at:")
                    Text("support@aftersplit.com")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }
}
