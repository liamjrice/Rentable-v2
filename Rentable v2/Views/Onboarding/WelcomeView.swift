//
//  WelcomeView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI

struct WelcomeView: View {
    
    // MARK: - Focus State
    
    enum Field: Hashable {
        case email
        case password
    }
    
    // MARK: - Properties
    
    @StateObject private var viewModel = OnboardingViewModel()
    @FocusState private var focusedField: Field?
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var hasInteractedWithEmail: Bool = false
    @State private var hasInteractedWithPassword: Bool = false
    @State private var navigateToSignup: Bool = false
    
    // MARK: - Computed Properties
    
    private var canProceed: Bool {
        if !viewModel.showPassword {
            return viewModel.isEmailValid && !email.isEmpty
        } else {
            return viewModel.isEmailValid && !email.isEmpty && !password.isEmpty
        }
    }
    
    private var emailValidationMessage: String? {
        guard hasInteractedWithEmail && !email.isEmpty else { return nil }
        return viewModel.isEmailValid ? nil : "Please enter a valid email address"
    }
    
    private var passwordValidationMessage: String? {
        guard hasInteractedWithPassword && !password.isEmpty else { return nil }
        return viewModel.passwordValidationMessage(password)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 40)
                        
                        // Header
                        headerSection
                        
                        // Form
                        formSection
                        
                        // Action Button
                        actionButton
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
                .scrollDismissesKeyboard(.interactively)
                
                // Loading Overlay
                if viewModel.isLoading || viewModel.isCheckingEmail {
                    loadingOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: email) { newValue in
                viewModel.email = newValue
                if viewModel.showPassword {
                    viewModel.showPassword = false
                    password = ""
                    hasInteractedWithPassword = false
                }
            }
            
            .disabled(viewModel.isLoading || viewModel.isCheckingEmail)
            .sheet(isPresented: $navigateToSignup) {
                SignupCoordinatorView(email: email, password: password)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "house.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            Text("Welcome to Rentable")
                .font(.title.bold())
            
            Text("Find your perfect rental or manage your properties")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(emailBorderColor, lineWidth: 1.5)
                    )
                    .onSubmit {
                        hasInteractedWithEmail = true
                        if viewModel.isEmailValid {
                            handleEmailSubmit()
                        }
                    }
                    .onChange(of: focusedField) { newValue in
                        if newValue != .email && !email.isEmpty {
                            hasInteractedWithEmail = true
                        }
                    }
                
                if let message = emailValidationMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }
            
            // Password Field (conditional)
            if viewModel.showPassword {
                VStack(alignment: .leading, spacing: 8) {
                    SecureField("Password", text: $password)
                        .textContentType(viewModel.emailExists ? .password : .newPassword)
                        .focused($focusedField, equals: .password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(passwordBorderColor, lineWidth: 1.5)
                        )
                        .onSubmit {
                            hasInteractedWithPassword = true
                            if canProceed {
                                handlePasswordSubmit()
                            }
                        }
                        .onChange(of: focusedField) { newValue in
                            if newValue != .password && !password.isEmpty {
                                hasInteractedWithPassword = true
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    
                    if let message = passwordValidationMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.red)
                            .transition(.opacity)
                    } else if !viewModel.emailExists && hasInteractedWithPassword && password.count >= 8 {
                        Text("Choose a strong password with letters and numbers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .transition(.opacity)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showPassword)
    }
    
    private var actionButton: some View {
        Button(action: handleAction) {
            HStack {
                if viewModel.isCheckingEmail || viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
        .disabled(!canProceed || viewModel.isCheckingEmail || viewModel.isLoading)
        .cornerRadius(12)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(viewModel.isCheckingEmail ? "Checking email..." : "Signing in...")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .padding(24)
            .background(Color(.systemGray))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Computed UI Properties
    
    private var emailBorderColor: Color {
        if !hasInteractedWithEmail || email.isEmpty {
            return .clear
        }
        return viewModel.isEmailValid ? .green : .red
    }
    
    private var passwordBorderColor: Color {
        if !hasInteractedWithPassword || password.isEmpty {
            return .clear
        }
        if viewModel.emailExists {
            // For sign in, just check it's not empty
            return password.isEmpty ? .clear : .green
        } else {
            // For sign up, validate strength
            return viewModel.isPasswordValid(password) ? .green : .red
        }
    }
    
    private var buttonTitle: String {
        if !viewModel.showPassword {
            return "Continue"
        } else {
            return viewModel.emailExists ? "Sign In" : "Create Account"
        }
    }
    
    // MARK: - Actions
    
    private func handleAction() {
        if !viewModel.showPassword {
            handleEmailSubmit()
        } else {
            handlePasswordSubmit()
        }
    }
    
    private func handleEmailSubmit() {
        hasInteractedWithEmail = true
        
        guard viewModel.isEmailValid else {
            return
        }
        
        // Dismiss keyboard
        focusedField = nil
        
        // Check email
        Task {
            await viewModel.checkEmail()
            
            // After checking, focus on password field if shown
            if viewModel.showPassword {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s delay
                focusedField = .password
            }
        }
    }
    
    private func handlePasswordSubmit() {
        hasInteractedWithPassword = true
        
        guard canProceed else {
            return
        }
        
        // Dismiss keyboard
        focusedField = nil
        
        if viewModel.emailExists {
            // Sign in existing user
            Task {
                await viewModel.signIn(password: password)
                // AppState will handle navigation after successful sign in
            }
        } else {
            // Navigate to signup flow with the entered password
            viewModel.prepareForSignUp()
            navigateToSignup = true
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
}

