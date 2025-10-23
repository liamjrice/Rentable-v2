//
//  VerificationView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI
import Combine


// MARK: - Shake Animation Modifier

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

extension View {
    func shake(animateTrigger: Int) -> some View {
        modifier(ShakeEffect(animatableData: CGFloat(animateTrigger)))
    }
}

// MARK: - VerificationView

struct VerificationView: View {
    
    // MARK: - Properties
    
    let email: String
    
    @StateObject private var viewModel = OnboardingViewModel()
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @State private var otpCode: String = ""
    @State private var isVerifying: Bool = false
    @State private var canResend: Bool = false
    @State private var countdown: Int = 60
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var shakeCount: Int = 0
    
    @FocusState private var isOTPFocused: Bool
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.blue.gradient)
                        .accessibilityLabel("Email verification")
                    
                    // Header
                    VStack(spacing: 8) {
                        Text("Check your email")
                            .font(.title.bold())
                        
                        Text("We sent a verification code to")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(email)
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)
                    }
                    
                    // OTP Input
                    VStack(spacing: 16) {
                        TextField("Enter 6-digit code", text: $otpCode)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .focused($isOTPFocused)
                            .onChange(of: otpCode) { oldValue, newValue in
                                handleOTPChange(newValue)
                            }
                            .disabled(isVerifying)
                            .shake(animateTrigger: shakeCount)
                            .accessibilityLabel("Verification code input")
                            .accessibilityHint("Enter the 6-digit code sent to your email")
                        
                        if isVerifying {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Verifying...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // MVP Testing Note
                        Text("For testing: Use code 123456")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 32)
                    
                    // Resend Button
                    Button(action: resendCode) {
                        if canResend {
                            Text("Resend Code")
                                .fontWeight(.semibold)
                        } else {
                            Text("Resend code in \(countdown)s")
                                .foregroundColor(.secondary)
                        }
                    }
                    .disabled(!canResend)
                    .accessibilityLabel(canResend ? "Resend verification code" : "Resend code available in \(countdown) seconds")
                    
                    Spacer()
                    
                    // Manual Verify Button
                    Button(action: verifyCode) {
                        Text("Verify")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(otpCode.count != 6 || isVerifying)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    .accessibilityLabel("Verify code")
                    .accessibilityHint("Verifies the entered code")
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .alert("Verification Failed", isPresented: $showError) {
                    Button("Try Again") {
                        otpCode = ""
                        isOTPFocused = true
                    }
                } message: {
                    Text(errorMessage)
                }
                .onAppear {
                    viewModel.email = email
                    isOTPFocused = true
                    startCountdown()
                }
                .onReceive(timer) { _ in
                    updateCountdown()
                }
                
                // Loading Overlay
                if isVerifying {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleOTPChange(_ newValue: String) {
        // Filter to only digits
        let filtered = newValue.filter { $0.isNumber }
        
        // Limit to 6 digits
        if filtered.count > 6 {
            otpCode = String(filtered.prefix(6))
        } else {
            otpCode = filtered
        }
        
        // Auto-submit when 6 digits entered
        if otpCode.count == 6 {
            // Small delay for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                verifyCode()
            }
        }
    }
    
    // MARK: - Actions
    
    private func verifyCode() {
        guard otpCode.count == 6 else { return }
        guard !isVerifying else { return }
        
        isVerifying = true
        isOTPFocused = false
        
        Task {
            let success = await viewModel.verifyOTP(code: otpCode)
            
            if success {
                await MainActor.run {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    dismiss()
                }
            } else {
                await MainActor.run {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    withAnimation(.default) { shakeCount += 1 }
                    errorMessage = "Invalid code. Please try again."
                    showError = true
                    isVerifying = false
                    otpCode = ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isOTPFocused = true
                    }
                }
            }
            
            isVerifying = false
        }
    }
    
    private func resendCode() {
        guard canResend else { return }
        
        // Reset countdown
        countdown = 60
        canResend = false
        
        // TODO: Resend OTP email via Supabase
        // This would trigger: await supabase.auth.resend(email: email, type: .signup)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Show success feedback
        withAnimation {
            // Could show a temporary success message
        }
    }
    
    private func startCountdown() {
        countdown = 60
        canResend = false
    }
    
    private func updateCountdown() {
        if countdown > 0 {
            countdown -= 1
        } else if !canResend {
            canResend = true
            
            // Haptic feedback when resend becomes available
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

// MARK: - Preview

#Preview {
    VerificationView(email: "test@example.com")
}


