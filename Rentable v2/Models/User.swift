//
//  User.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import Foundation

enum UserRole: String, Codable {
    case tenant
    case landlord
}

struct AppUser: Codable, Identifiable {
    let id: String
    let email: String
    let role: UserRole
    let createdAt: Date
}

