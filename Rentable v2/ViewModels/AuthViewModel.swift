//
//  AuthViewModel.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let authService: AuthServicing
    
    init(authService: AuthServicing = AuthService()) {
        self.authService = authService
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        error = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            print("✅ Signed in successfully: \(user.email)")
            // Handle successful sign in (e.g., navigate to main screen)
        } catch {
            self.error = error.localizedDescription
            print("❌ Sign in failed: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String, role: UserRole) async {
        isLoading = true
        error = nil
        
        do {
            let user = try await authService.signUp(email: email, password: password, role: role)
            print("✅ Signed up successfully: \(user.email)")
            // Handle successful sign up
        } catch {
            self.error = error.localizedDescription
            print("❌ Sign up failed: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        error = nil
        
        do {
            try await authService.signOut()
            print("✅ Signed out successfully")
            // Handle successful sign out
        } catch {
            self.error = error.localizedDescription
            print("❌ Sign out failed: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

