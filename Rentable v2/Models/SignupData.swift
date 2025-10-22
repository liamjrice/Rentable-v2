//
//  SignupData.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import Foundation
import UIKit

/// Holds all signup form data during the onboarding flow
struct SignupData {
    var email: String = ""
    var password: String = ""
    var fullName: String = ""
    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    var phoneNumber: String = ""
    var address: String = ""
    var profileImage: UIImage?
    var userType: UserType = .tenant
    
    // MARK: - Validation Properties
    
    var isNameValid: Bool {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2
    }
    
    var isDOBValid: Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        let age = ageComponents.year ?? 0
        return age >= 18
    }
    
    var isPhoneValid: Bool {
        // UK mobile number validation (07XXX XXX XXX or 07XXXXXXXXX)
        let phoneRegex = "^07\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let cleanedPhone = phoneNumber.replacingOccurrences(of: " ", with: "")
        return phonePredicate.evaluate(with: cleanedPhone)
    }
    
    var isAddressValid: Bool {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 5
    }
    
    // Photo is optional, so always valid
    var isPhotoValid: Bool {
        return true
    }
    
    // MARK: - Computed Properties
    
    var formattedPhoneNumber: String {
        let cleaned = phoneNumber.replacingOccurrences(of: " ", with: "")
        if cleaned.count == 11 {
            // Format as 07XXX XXX XXX
            let index1 = cleaned.index(cleaned.startIndex, offsetBy: 5)
            let index2 = cleaned.index(cleaned.startIndex, offsetBy: 8)
            return "\(cleaned[..<index1]) \(cleaned[index1..<index2]) \(cleaned[index2...])"
        }
        return cleaned
    }
    
    // MARK: - Conversion
    
    /// Converts signup data to User model
    func toUser(id: UUID, createdAt: Date = Date()) -> User {
        return User(
            id: id,
            email: email,
            fullName: fullName,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber.replacingOccurrences(of: " ", with: ""),
            address: address,
            profileImageURL: nil, // Will be updated after image upload
            userType: userType,
            createdAt: createdAt
        )
    }
}

