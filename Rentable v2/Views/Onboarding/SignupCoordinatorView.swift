//
//  SignupCoordinatorView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI

/// Defines the signup flow steps
enum SignupStep: Hashable {
    case name
    case dob
    case phone
    case address
    case photo
}

/// Coordinates the signup flow with NavigationStack
struct SignupCoordinatorView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var signupData = SignupData()
    @State private var navigationPath = NavigationPath()
    @State private var showVerification = false
    
    let email: String
    let password: String
    
    // MARK: - Computed Properties
    
    private var currentStepNumber: Int {
        navigationPath.count + 1
    }
    
    private var totalSteps: Int {
        5
    }
    
    private var progress: Double {
        Double(currentStepNumber) / Double(totalSteps)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            welcomeScreen
                .navigationDestination(for: SignupStep.self) { step in
                    destinationView(for: step)
                }
        }
        .sheet(isPresented: $showVerification) {
            VerificationView(email: email)
        }
        .onAppear {
            // Pre-populate email from welcome screen
            signupData.email = email
            signupData.password = password
        }
    }
    
    // MARK: - Welcome Screen
    
    private var welcomeScreen: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill.badge.plus")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)
                
                Text("Create Your Account")
                    .font(.title.bold())
                
                Text("Let's get to know you better. This will only take a minute.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Continue Button
            Button {
                navigationPath.append(SignupStep.name)
            } label: {
                Text("Let's Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Destination Views
    
    @ViewBuilder
    private func destinationView(for step: SignupStep) -> some View {
        Group {
            switch step {
            case .name:
                NameStepView(
                    signupData: $signupData,
                    onContinue: { navigationPath.append(SignupStep.dob) }
                )
                
            case .dob:
                DateOfBirthStepView(
                    signupData: $signupData,
                    onContinue: { navigationPath.append(SignupStep.phone) }
                )
                
            case .phone:
                PhoneStepView(
                    signupData: $signupData,
                    onContinue: { navigationPath.append(SignupStep.address) }
                )
                
            case .address:
                AddressStepView(
                    signupData: $signupData,
                    onContinue: { navigationPath.append(SignupStep.photo) }
                )
                
            case .photo:
                PhotoStepView(
                    signupData: $signupData,
                    onContinue: { handleSignup() }
                )
            }
        }
        .safeAreaInset(edge: .top) {
            progressIndicator
        }
    }
    
    // MARK: - Progress Indicator
    
    private var progressIndicator: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Step \(currentStepNumber) of \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            
            ProgressView(value: progress)
                .tint(.blue)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
    
    // MARK: - Actions
    
    private func handleSignup() {
        Task {
            do {
                // Create user account
                let userId = UUID()
                let user = signupData.toUser(id: userId)
                
                let session = try await AuthenticationService.shared.signUp(
                    email: signupData.email,
                    password: signupData.password,
                    userData: user
                )
                
                // Upload profile image if provided
                if let image = signupData.profileImage {
                    _ = try await AuthenticationService.shared.uploadProfileImage(
                        userId: userId,
                        image: image
                    )
                }
                
                // Show verification screen
                showVerification = true
                
            } catch {
                // Handle error - show alert
                print("Signup error: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SignupCoordinatorView(email: "test@example.com", password: "password123")
}

