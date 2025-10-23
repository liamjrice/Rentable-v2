//
//  Rentable_v2App.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import SwiftUI
import Supabase

@main
struct Rentable_v2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - State
    
    @StateObject private var coordinator = AppCoordinator.shared
    @SwiftUI.Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Initialization
    
    init() {
        // Supabase is already initialized in SupabaseManager.shared
        // Additional setup can go here if needed
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content based on authentication state
                if coordinator.isInitializing {
                    // Loading screen
                    loadingView
                } else {
                    Group {
                        switch coordinator.currentFlow {
                        case .onboarding:
                            WelcomeView()
                                .transition(.opacity)
                        case .main:
                            MainTabView()
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: coordinator.currentFlow)
                }
            }
            .environmentObject(coordinator)
            .environmentObject(coordinator.appState)
            .onOpenURL { url in
                // Handle deep links
                coordinator.handleDeepLink(url)
            }
            .onChange(of: coordinator.appState.isAuthenticated) { oldValue, newValue in
                // Update flow when auth state changes
                Task {
                    await coordinator.initialize()
                }
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(newPhase)
            }
        }
    }
    
    // MARK: - Views
    
    private var loadingView: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "house.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Scene Phase Handling
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // App became active
            Task {
                // Refresh session if needed
                if coordinator.appState.isAuthenticated {
                    await coordinator.appState.restoreSession()
                }
            }
            
        case .inactive:
            // App became inactive (e.g., control center opened)
            break
            
        case .background:
            // App went to background
            // Could save any pending data here
            break
            
        @unknown default:
            break
        }
    }
}
