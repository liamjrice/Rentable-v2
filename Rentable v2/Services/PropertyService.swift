//
//  PropertyService.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import Foundation
import Supabase

protocol PropertyServicing {
    func fetchAll() async throws -> [Property]
}

class PropertyService: PropertyServicing {
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }
    
    func fetchAll() async throws -> [Property] {
        let properties: [Property] = try await client
            .from("properties")
            .select()
            .execute()
            .value
        
        return properties
    }
}

