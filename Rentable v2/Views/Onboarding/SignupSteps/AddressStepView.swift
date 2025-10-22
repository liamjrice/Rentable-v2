//
//  AddressStepView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI

struct AddressStepView: View {
    
    // MARK: - Focus Fields
    
    enum Field: Hashable {
        case street
        case city
        case postcode
    }
    
    // MARK: - Properties
    
    @Binding var signupData: SignupData
    let onContinue: () -> Void
    
    @FocusState private var focusedField: Field?
    @State private var street: String = ""
    @State private var city: String = ""
    @State private var postcode: String = ""
    @State private var hasInteracted = false
    
    // MARK: - Computed Properties
    
    private var isValid: Bool {
        isStreetValid && isCityValid && isPostcodeValid
    }
    
    private var isStreetValid: Bool {
        !street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isCityValid: Bool {
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isPostcodeValid: Bool {
        // UK postcode validation
        let postcodeRegex = "^[A-Z]{1,2}\\d{1,2}[A-Z]?\\s?\\d[A-Z]{2}$"
        let postcodePredicate = NSPredicate(format: "SELF MATCHES %@", postcodeRegex)
        let cleanedPostcode = postcode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return postcodePredicate.evaluate(with: cleanedPostcode)
    }
    
    private var postcodeValidationMessage: String? {
        guard hasInteracted && !postcode.isEmpty else { return nil }
        if !isPostcodeValid {
            return "Please enter a valid UK postcode (e.g., SW1A 1AA)"
        }
        return nil
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Where do you live?")
                        .font(.title.bold())
                    
                    Text("Enter your current address")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            }
            
            Section("Address Details") {
                // Street Address
                TextField("Street Address", text: $street)
                    .textContentType(.streetAddressLine1)
                    .autocapitalization(.words)
                    .focused($focusedField, equals: .street)
                    .onSubmit {
                        focusedField = .city
                    }
                    .accessibilityLabel("Street address")
                    .onChange(of: street) { _ in
                        updateAddress()
                    }
                
                // City
                TextField("City", text: $city)
                    .textContentType(.addressCity)
                    .autocapitalization(.words)
                    .focused($focusedField, equals: .city)
                    .onSubmit {
                        focusedField = .postcode
                    }
                    .accessibilityLabel("City")
                    .onChange(of: city) { _ in
                        updateAddress()
                    }
                
                // Postcode
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Postcode", text: $postcode)
                        .textContentType(.postalCode)
                        .autocapitalization(.allCharacters)
                        .focused($focusedField, equals: .postcode)
                        .onSubmit {
                            hasInteracted = true
                            focusedField = nil
                            if isValid {
                                onContinue()
                            }
                        }
                        .accessibilityLabel("Postcode")
                        .onChange(of: postcode) { newValue in
                            postcode = newValue.uppercased()
                            updateAddress()
                        }
                        .onChange(of: focusedField) { field in
                            if field != .postcode {
                                hasInteracted = true
                            }
                        }
                    
                    if let message = postcodeValidationMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Example:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("123 High Street")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("London")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("SW1A 1AA")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .navigationTitle("Address")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Button("Previous") {
                        moveFocusBack()
                    }
                    .disabled(focusedField == .street)
                    
                    Spacer()
                    
                    Button("Next") {
                        moveFocusForward()
                    }
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    hasInteracted = true
                    focusedField = nil
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
                .accessibilityLabel("Continue to next step")
                .accessibilityHint("Continues to profile photo step")
            }
        }
        .onAppear {
            // Parse existing address if any
            if !signupData.address.isEmpty {
                let components = signupData.address.components(separatedBy: ", ")
                if components.count >= 3 {
                    street = components[0]
                    city = components[1]
                    postcode = components[2]
                }
            }
            focusedField = .street
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateAddress() {
        signupData.address = "\(street), \(city), \(postcode)"
    }
    
    private func moveFocusForward() {
        switch focusedField {
        case .street:
            focusedField = .city
        case .city:
            focusedField = .postcode
        case .postcode:
            focusedField = nil
        case .none:
            break
        }
    }
    
    private func moveFocusBack() {
        switch focusedField {
        case .street:
            break
        case .city:
            focusedField = .street
        case .postcode:
            focusedField = .city
        case .none:
            focusedField = .postcode
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AddressStepView(
            signupData: .constant(SignupData()),
            onContinue: { print("Continue") }
        )
    }
}

