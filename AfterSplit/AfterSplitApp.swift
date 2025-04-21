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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CameraViewModelSec())
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
