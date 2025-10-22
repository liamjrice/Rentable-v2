//
//  User.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import Foundation

enum UserType: String, Codable {
    case tenant
    case landlord
}

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    var fullName: String?
    var dateOfBirth: Date?
    var phoneNumber: String?
    var address: String?
    var profileImageURL: String?
    let userType: UserType
    let createdAt: Date
    
    // MARK: - Computed Properties
    
    /// Checks if user is 18 years or older
    var isAdult: Bool {
        guard let dob = dateOfBirth else { return false }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        return (ageComponents.year ?? 0) >= 18
    }
    
    // MARK: - Coding Keys
    
    /// Maps Swift camelCase properties to Supabase snake_case columns
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case dateOfBirth = "date_of_birth"
        case phoneNumber = "phone_number"
        case address
        case profileImageURL = "profile_image_url"
        case userType = "user_type"
        case createdAt = "created_at"
    }
}

// MARK: - Legacy Support
typealias AppUser = User
typealias UserRole = UserType

