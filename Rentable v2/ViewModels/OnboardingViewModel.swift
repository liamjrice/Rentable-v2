//
//  OnboardingViewModel.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import Foundation
import Combine
import Supabase

/// ViewModel for managing onboarding flow state and validation
@MainActor
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // UI State
    @Published var email: String = ""
    @Published var isCheckingEmail: Bool = false
    @Published var emailExists: Bool = false
    @Published var showPassword: Bool = false
    
    // Loading & Error States
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var showError: Bool = false
    
    // MARK: - Private Properties
    
    private let authService = AuthenticationService.shared
    private let appState = AppState.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Don't store password - handle it transiently in views
    
    // MARK: - Computed Properties
    
    /// Validates email format using regex
    var isEmailValid: Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    /// Validates password strength
    func isPasswordValid(_ password: String) -> Bool {
        // Minimum 8 characters, at least one letter and one number
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    /// Returns password validation message
    func passwordValidationMessage(_ password: String) -> String? {
        if password.isEmpty {
            return nil
        }
        
        if password.count < 8 {
            return "Password must be at least 8 characters"
        }
        
        if !password.contains(where: { $0.isLetter }) {
            return "Password must contain at least one letter"
        }
        
        if !password.contains(where: { $0.isNumber }) {
            return "Password must contain at least one number"
        }
        
        return nil
    }
    
    // MARK: - Public Methods
    
    /// Checks if email exists in the system
    func checkEmail() async {
        guard isEmailValid else {
            showErrorMessage("Please enter a valid email address")
            return
        }
        
        isCheckingEmail = true
        errorMessage = nil
        
        do {
            emailExists = try await authService.checkEmailExists(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
            showPassword = true
        } catch {
            showErrorMessage("Failed to check email. Please try again.")
        }
        
        isCheckingEmail = false
    }
    
    /// Signs in existing user
    func signIn(password: String) async {
        guard isEmailValid else {
            showErrorMessage("Please enter a valid email address")
            return
        }
        
        guard !password.isEmpty else {
            showErrorMessage("Please enter your password")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signIn(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password
            )
            
            // Update app state
            appState.updateUser(user)
            
        } catch let error as AuthError {
            showErrorMessage(error.localizedDescription ?? "Sign in failed")
        } catch {
            showErrorMessage("An unexpected error occurred")
        }
        
        isLoading = false
    }
    
    /// Prepares for sign up flow (called from welcome view)
    func prepareForSignUp() {
        // Email is already validated and doesn't exist
        // Navigate to signup flow
        showPassword = false
    }
    
    /// Verifies OTP code
    func verifyOTP(code: String) async -> Bool {
        guard code.count == 6 else {
            showErrorMessage("Please enter a valid 6-digit code")
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.verifyOTP(
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                code: code
            )
            
            // After verification, update app state
            appState.updateUser(user)
            
            isLoading = false
            return true
            
        } catch {
            showErrorMessage("Invalid verification code. Please try again.")
            isLoading = false
            return false
        }
    }
    
    /// Resets the onboarding state
    func reset() {
        email = ""
        emailExists = false
        showPassword = false
        isLoading = false
        errorMessage = nil
        showError = false
    }
    
    // MARK: - Private Methods
    
    /// Shows an error message to the user
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    /// Clears the current error
    func clearError() {
        errorMessage = nil
        showError = false
    }
}

