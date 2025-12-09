//
//  AfterSplitApp.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 02/03/2025.
//

import SwiftData
import SwiftUI

@main
struct MultiCameraApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var subscriptionStateManager = SubscriptionStateManager.shared
    
    init() {
        // Initialize Firebase
        if AppConfig.firebaseEnabled {
            FirebaseManager.shared.configure()
        }
        
        // Initialize RevenueCat
        let revenueCatAPIKey = AppConfig.revenueCatAPIKey
        if !revenueCatAPIKey.isEmpty && revenueCatAPIKey != "YOUR_REVENUECAT_API_KEY" {
            RevenueCatManager.shared.configure(apiKey: revenueCatAPIKey)
        }
        
        // Initialize Superwall
        let superwallAPIKey = AppConfig.superwallAPIKey
        if !superwallAPIKey.isEmpty && superwallAPIKey != "YOUR_SUPERWALL_API_KEY" {
            SuperwallManager.shared.configure(apiKey: superwallAPIKey)
        }
        
        // Set up analytics
        AnalyticsManager.shared.trackAppLaunch()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CameraViewModelSec())
                .environmentObject(subscriptionStateManager)
                .paywallPresentation()
                .onAppear {
                    // Check for subscription restoration
                    Task {
                        await subscriptionStateManager.refreshSubscriptionStatus()
                    }
                    
                    // Check paywall trigger after onboarding
                    if hasCompletedOnboarding {
                        PaywallTriggerManager.shared.checkTriggerAfterOnboarding()
                    }
                }
        }
    }
}
//@main
//struct AfterSplitApp: App {
//    // Dependency Injection
//    private let storageService = CoreDataStorageService()
//    private let cameraManager = CameraManager()
//    
//    // Initialize repository with storage service
//    private var cameraRepository: CameraRepository {
//        CameraRepository(storageService: storageService)
//    }
//    
//    // Initialize use case with repository and camera manager
//    private var cameraUseCase: CameraUseCase {
//        CameraUseCase(cameraRepository: cameraRepository, cameraManager: cameraManager)
//    }
//    
//    // Initialize view model with use case
//    private var cameraViewModel: CameraViewModel {
//        CameraViewModel(cameraUseCase: cameraUseCase)
//    }
//    
//    // State for onboarding
//    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
//    @State private var showOnboarding = false
//    
//    init() {
//        // Initialize Core Data
//        storageService.setupCoreDataModel()
//        
//        // Check if this is first launch
//        if !hasCompletedOnboarding {
//            showOnboarding = true
//        }
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            ZStack {
//                ASContentView(viewModel: cameraViewModel)
//                    .onDisappear {
//                        // Clean up resources when app disappears
//                        cameraViewModel.cleanup()
//                    }
//                    .onAppear {
//                        // Show onboarding if needed
//                        if !hasCompletedOnboarding {
//                            showOnboarding = true
//                        }
//                    }
//                
//                if showOnboarding {
//                    OnboardingView(showOnboarding: $showOnboarding)
//                        .transition(.opacity)
//                        .zIndex(1)
//                        .onChange(of: showOnboarding) { newValue in
//                            if !newValue {
//                                // User completed onboarding
//                                hasCompletedOnboarding = true
//                            }
//                        }
//                }
//            }
//            .animation(.easeInOut, value: showOnboarding)
//        }
//    }
//}
