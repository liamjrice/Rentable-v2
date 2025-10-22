//
//  DateOfBirthStepView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI

struct DateOfBirthStepView: View {
    
    // MARK: - Properties
    
    @Binding var signupData: SignupData
    let onContinue: () -> Void
    
    @State private var hasInteracted = false
    
    // MARK: - Computed Properties
    
    private var isValid: Bool {
        signupData.isDOBValid
    }
    
    private var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: signupData.dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: signupData.dateOfBirth)
    }
    
    private var validationMessage: String? {
        guard hasInteracted else { return nil }
        if age < 18 {
            return "You must be at least 18 years old to use Rentable"
        }
        return nil
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("When's your birthday?")
                        .font(.title.bold())
                    
                    Text("You must be 18 or older to use Rentable")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                // Date Picker
                VStack(spacing: 16) {
                    DatePicker(
                        "Date of Birth",
                        selection: $signupData.dateOfBirth,
                        in: ...Date.now.addingTimeInterval(-18 * 365 * 24 * 60 * 60),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .onChange(of: signupData.dateOfBirth) { _ in
                        hasInteracted = true
                    }
                    .accessibilityLabel("Date of birth picker")
                    .accessibilityHint("Select your date of birth. Must be 18 or older")
                    
                    // Display formatted date
                    VStack(spacing: 8) {
                        Text(formattedDate)
                            .font(.headline)
                        
                        if hasInteracted {
                            if isValid {
                                Label("Age: \(age) years old", systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            } else if let message = validationMessage {
                                Label(message, systemImage: "exclamationmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Date of Birth")
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
                .accessibilityLabel("Continue to phone number")
                .accessibilityHint("Proceeds to the next step after confirming age eligibility")
            }
        }
        .onAppear {
            hasInteracted = true
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DateOfBirthStepView(
            signupData: .constant(SignupData()),
            onContinue: { print("Continue") }
        )
    }
}

