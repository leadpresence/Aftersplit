
 
import AVFoundation
import CoreImage
import Foundation
import SwiftUI
struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    
    
 
  
    
    var body: some View {
        TabView {
            OnboardingPageView(
                title: "Welcome to AfterSplit",
                description: "Capture photos and videos using both front and back cameras simultaneously.",
                imageName: "camera.on.rectangle",
                buttonTitle: "Next",
                action: {}
            )
            
            OnboardingPageView(
                title: "Choose Your Style",
                description: "Select from different split styles to create unique dual-camera compositions.",
                imageName: "rectangle.split.2x1",
                buttonTitle: "Next",
                action: {}
            )
            
            OnboardingPageView(
                title: "Apply Filters",
                description: "Enhance your captures with creative filters.",
                imageName: "camera.filters",
                buttonTitle: "Next",
                action: {}
            )
            
            OnboardingPageView(
                title: "Let's Get Started!",
                description: "Create fun memories with friends and family.",
                imageName: "person.2.fill",
                buttonTitle: "Get Started",
                action: {
                    showOnboarding = false
                }
            )
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
 
}//
 
