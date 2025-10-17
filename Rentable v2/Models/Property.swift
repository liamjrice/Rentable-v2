//
//  Property.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import Foundation

struct Property: Codable, Identifiable {
    let id: String
    let landlordId: String
    let title: String
    let description: String
    let monthlyRent: Decimal
    let bedrooms: Int
    let location: String
    let createdAt: Date
}

