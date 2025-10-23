//
//  AppState.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import Foundation
import Supabase
import Combine

/// Single source of truth for app-wide authentication state
@MainActor
class AppState: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AppState()
    
    // MARK: - Published Properties
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = true
    
    // MARK: - Private Properties
    
    private let client = SupabaseManager.shared.client
    private var authStateTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        setupAuthStateListener()
        Task {
            await restoreSession()
        }
    }
    
    // MARK: - Public Methods
    
    /// Restores user session if available
    func restoreSession() async {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
       // Check if we have an active session directly from client
guard let session = client.auth.currentSession else {
    isAuthenticated = false
    currentUser = nil
    return
}
let userId = session.user.id

// Fetch user profile
do {
    let user: User = try await client
        .from("profiles")
        .select()
        .eq("id", value: userId.uuidString)
        .single()
        .execute()
        .value
            
            currentUser = user
            isAuthenticated = true
        } catch {
            print("Failed to restore session: \(error)")
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    /// Updates the current user
    func updateUser(_ user: User) {
        currentUser = user
        isAuthenticated = true
    }
    
    /// Clears the current user session
    func clearSession() {
        currentUser = nil
        isAuthenticated = false
    }
    
    /// Signs out the current user
    func signOut() async {
        do {
            // Call signOut directly on client instead of through actor
            try await client.auth.signOut()
            clearSession()
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up listener for Supabase auth state changes
    private func setupAuthStateListener() {
        authStateTask = Task { [weak self] in
            guard let self = self else { return }
            
            for await (event, session) in await self.client.auth.authStateChanges {
                await MainActor.run {
                    Task {
                        await self.handleAuthStateChange(event, session: session)
                    }
                }
            }
        }
    }
    
    /// Handles authentication state changes
    private func handleAuthStateChange(_ event: AuthChangeEvent, session: Session?) async {
        switch event {
        case .signedIn:
            // User signed in, restore their session
            await restoreSession()
            
        case .signedOut:
            // User signed out, clear session
            clearSession()
            
        case .userUpdated:
            // User data updated, refresh profile
            if let userId = client.auth.currentSession?.user.id {
                do {
                    let user: User = try await client
                        .from("profiles")
                        .select()
                        .eq("id", value: userId.uuidString)
                        .single()
                        .execute()
                        .value
                    
                    currentUser = user
                } catch {
                    print("Failed to fetch updated user: \(error)")
                }
            }
            
        case .passwordRecovery:
            // Handle password recovery if needed
            break
            
        case .tokenRefreshed:
            // Token refreshed, session is still valid
            break
            
        default:
            break
        }
    }
    
    deinit {
        authStateTask?.cancel()
    }
}