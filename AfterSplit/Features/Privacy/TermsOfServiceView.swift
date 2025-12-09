//
//  TermsOfServiceView.swift
//  AfterSplit
//
//  Terms of Service view
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Last Updated: \(Date(), style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                SectionView(title: "Acceptance of Terms") {
                    Text("By downloading, installing, or using AfterSplit, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.")
                }
                
                SectionView(title: "Subscription Terms") {
                    Text("AfterSplit offers subscription services:")
                    BulletPoint("7-day trial for $0.39")
                    BulletPoint("Monthly subscription for $3.99")
                    BulletPoint("Yearly subscription for $29.99")
                    Text("\nSubscriptions automatically renew unless cancelled at least 24 hours before the end of the current period.")
                }
                
                SectionView(title: "Cancellation") {
                    Text("You can cancel your subscription at any time through your Apple ID account settings. Cancellation will take effect at the end of the current billing period.")
                }
                
                SectionView(title: "Refunds") {
                    Text("Refunds are handled according to Apple's refund policy. If you are not satisfied with your purchase, you may request a refund through Apple.")
                }
                
                SectionView(title: "User Content") {
                    Text("You retain all rights to photos and videos you create using AfterSplit. We do not claim ownership of your content.")
                }
                
                SectionView(title: "Prohibited Uses") {
                    Text("You agree not to:")
                    BulletPoint("Use the app for any illegal purpose")
                    BulletPoint("Violate any laws or regulations")
                    BulletPoint("Infringe on intellectual property rights")
                    BulletPoint("Upload malicious code or viruses")
                }
                
                SectionView(title: "Disclaimer") {
                    Text("AfterSplit is provided 'as is' without warranties of any kind. We are not responsible for any loss or damage resulting from your use of the app.")
                }
                
                SectionView(title: "Limitation of Liability") {
                    Text("To the maximum extent permitted by law, AfterSplit shall not be liable for any indirect, incidental, or consequential damages.")
                }
                
                SectionView(title: "Changes to Terms") {
                    Text("We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.")
                }
                
                SectionView(title: "Contact Us") {
                    Text("If you have questions about these Terms, please contact us at:")
                    Text("support@aftersplit.com")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}
