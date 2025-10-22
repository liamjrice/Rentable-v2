//
//  AppCoordinator.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import Foundation
import SwiftUI
import Supabase

/// Defines the major app flows
enum AppFlow {
    case onboarding
    case main
}

/// Main app coordinator managing navigation and state
@MainActor
class AppCoordinator: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AppCoordinator()
    
    // MARK: - Published Properties
    
    @Published var appState: AppState
    @Published var currentFlow: AppFlow = .onboarding
    @Published var isInitializing: Bool = true
    
    // MARK: - Private Properties
    
    private let authService = AuthenticationService.shared
    private var authStateTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    private init() {
        self.appState = AppState.shared
        
        Task {
            await initialize()
        }
    }
    
    // MARK: - Public Methods
    
    /// Initializes the app coordinator
    func initialize() async {
        isInitializing = true
        
        // Restore session if exists
        await appState.restoreSession()
        
        // Update flow based on auth state
        updateFlow()
        
        // Setup auth state listener
        setupAuthStateListener()
        
        isInitializing = false
    }
    
    /// Handles deep links
    func handleDeepLink(_ url: URL) {
        // Check if it's a Supabase auth callback
        if url.host == "auth-callback" || url.pathComponents.contains("auth") {
            handleAuthCallback(url)
        }
        
        // Handle other deep links
        // TODO: Add custom deep link handling (e.g., property links, chat links)
    }
    
    /// Handles logout
    func logout() async {
        await appState.signOut()
        currentFlow = .onboarding
    }
    
    // MARK: - Private Methods
    
    /// Updates the current flow based on authentication state
    private func updateFlow() {
        if appState.isAuthenticated {
            currentFlow = .main
        } else {
            currentFlow = .onboarding
        }
    }
    
    /// Sets up listener for auth state changes
    private func setupAuthStateListener() {
        // Observe auth state changes from AppState
        authStateTask = Task { [weak self] in
            guard let self = self else { return }
            
            // We'll use a simple timer to check for auth state changes
            // In a real app, you might use Combine publishers
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                
                await MainActor.run {
                    self.updateFlow()
                }
            }
        }
    }
    
    /// Handles Supabase auth callback URLs
    private func handleAuthCallback(_ url: URL) {
        // Parse URL components
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }
        
        // Extract tokens if present
        var accessToken: String?
        var refreshToken: String?
        var type: String?
        
        for item in queryItems {
            switch item.name {
            case "access_token":
                accessToken = item.value
            case "refresh_token":
                refreshToken = item.value
            case "type":
                type = item.value
            default:
                break
            }
        }
        
        // Handle different callback types
        if type == "signup" || type == "magiclink" {
            // Email verification complete
            Task {
                await appState.restoreSession()
            }
        }
    }
    
    deinit {
        authStateTask?.cancel()
    }
}

// MARK: - Deep Link Handler

extension AppCoordinator {
    /// Convenience method to handle URL schemes
    func canHandleURL(_ url: URL) -> Bool {
        // Check if URL is for this app
        return url.scheme == "rentable" || url.host?.contains("supabase") == true
    }
}

