//
//  PhoneStepView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI
import Combine

struct PhoneStepView: View {
    
    // MARK: - Properties
    
    @Binding var signupData: SignupData
    let onContinue: () -> Void
    
    @FocusState private var isPhoneFocused: Bool
    @State private var hasInteracted = false
    @State private var displayPhone = ""
    
    // MARK: - Computed Properties
    
    private var isValid: Bool {
        signupData.isPhoneValid
    }
    
    private var validationMessage: String? {
        guard hasInteracted && !signupData.phoneNumber.isEmpty else { return nil }
        if !isValid {
            return "Please enter a valid UK mobile number (07XXX XXX XXX)"
        }
        return nil
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your phone number?")
                        .font(.title.bold())
                    
                    Text("We'll use this to contact you about your rentals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                // Phone Input
                VStack(alignment: .leading, spacing: 8) {
                    TextField("07XXX XXX XXX", text: $displayPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                        .focused($isPhoneFocused)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: 1.5)
                        )
                        .onChange(of: displayPhone) { newValue in
                            formatPhoneNumber(newValue)
                            hasInteracted = true
                        }
                        .onChange(of: isPhoneFocused) { focused in
                            if !focused {
                                hasInteracted = true
                            }
                        }
                        .accessibilityLabel("Phone number")
                        .accessibilityHint("Enter your UK mobile number starting with 07")
                    
                    if let message = validationMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    if isValid && hasInteracted {
                        Label("Valid UK mobile number", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    Text("UK mobile numbers only")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Phone Number")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isPhoneFocused = false
                    }
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    hasInteracted = true
                    isPhoneFocused = false
                    if isValid {
                        onContinue()
                    }
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(!isValid)
                .cornerRadius(12)
                .accessibilityLabel("Continue to address")
                .accessibilityHint("Proceeds to the next step after entering valid phone number")
            }
        }
        .onAppear {
            isPhoneFocused = true
            displayPhone = signupData.phoneNumber
        }
    }
    
    // MARK: - Computed UI Properties
    
    private var borderColor: Color {
        if !hasInteracted || signupData.phoneNumber.isEmpty {
            return .clear
        }
        return isValid ? .green : .red
    }
    
    // MARK: - Helper Methods
    
    private func formatPhoneNumber(_ value: String) {
        // Remove all non-numeric characters
        let cleaned = value.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Limit to 11 digits
        let limited = String(cleaned.prefix(11))
        signupData.phoneNumber = limited
        
        // Format as 07XXX XXX XXX
        if limited.count >= 5 {
            let index1 = limited.index(limited.startIndex, offsetBy: 5)
            var formatted = String(limited[..<index1])
            
            if limited.count > 5 {
                let index2 = limited.index(limited.startIndex, offsetBy: min(8, limited.count))
                formatted += " " + String(limited[index1..<index2])
                
                if limited.count > 8 {
                    formatted += " " + String(limited[index2...])
                }
            }
            
            displayPhone = formatted
        } else {
            displayPhone = limited
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PhoneStepView(
            signupData: .constant(SignupData()),
            onContinue: { print("Continue") }
        )
    }
}

