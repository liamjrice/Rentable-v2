import Foundation
import SwiftUI
import Combine
import Supabase

/// Defines the major app flows
enum AppFlow {
    case onboarding
    case main
}

/// Main app coordinator managing navigation and state
@MainActor
final class AppCoordinator: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AppCoordinator()
    
    // MARK: - Published Properties
    
    @Published var appState: AppState
    @Published var currentFlow: AppFlow = .onboarding
    @Published var isInitializing: Bool = true
    
    // MARK: - Private Properties
    
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
        authStateTask = Task { [weak self] in
            guard let self = self else { return }
            
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000)
                
                await MainActor.run {
                    self.updateFlow()
                }
            }
        }
    }
    
    /// Handles Supabase auth callback URLs
    private func handleAuthCallback(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }
        
        var accessToken: String?
        var type: String?
        
        for item in queryItems {
            switch item.name {
            case "access_token":
                accessToken = item.value
            case "type":
                type = item.value
            default:
                break
            }
        }
        
        if type == "signup" || type == "magiclink" {
            Task {
                await appState.restoreSession()
            }
        }
    }
    
    deinit {
        authStateTask?.cancel()
    }
}