//
//  OnboardingPage.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 12/04/2025.
//
import SwiftUI

struct OnboardingPageView: View {
    let title: String
    let description: String
    let imageName: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .padding()
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: action) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 50)
        }
    }
}
