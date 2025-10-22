//
//  NameStepView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI

struct NameStepView: View {
    
    // MARK: - Properties
    
    @Binding var signupData: SignupData
    let onContinue: () -> Void
    
    @FocusState private var isNameFocused: Bool
    @State private var hasInteracted = false
    
    // MARK: - Computed Properties
    
    private var isValid: Bool {
        signupData.isNameValid
    }
    
    private var validationMessage: String? {
        guard hasInteracted && !signupData.fullName.isEmpty else { return nil }
        if signupData.fullName.count < 2 {
            return "Name must be at least 2 characters"
        }
        return nil
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your name?")
                        .font(.title.bold())
                    
                    Text("Enter your full legal name as it appears on your ID")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Full Name", text: $signupData.fullName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                        .autocorrectionDisabled(false)
                        .focused($isNameFocused)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: 1.5)
                        )
                        .onSubmit {
                            hasInteracted = true
                            if isValid {
                                onContinue()
                            }
                        }
                        .onChange(of: isNameFocused) { focused in
                            if !focused {
                                hasInteracted = true
                            }
                        }
                        .accessibilityLabel("Full name")
                        .accessibilityHint("Enter your full legal name")
                    
                    HStack {
                        if let message = validationMessage {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if isValid && hasInteracted {
                            Label("Looks good!", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        // Character count
                        if !signupData.fullName.isEmpty {
                            Text("\(signupData.fullName.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Your Name")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    hasInteracted = true
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
                .accessibilityLabel("Continue to date of birth")
                .accessibilityHint("Proceeds to the next step after entering your name")
            }
        }
        .onAppear {
            isNameFocused = true
        }
    }
    
    // MARK: - Computed UI Properties
    
    private var borderColor: Color {
        if !hasInteracted || signupData.fullName.isEmpty {
            return .clear
        }
        return isValid ? .green : .red
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NameStepView(
            signupData: .constant(SignupData()),
            onContinue: { print("Continue") }
        )
    }
}

