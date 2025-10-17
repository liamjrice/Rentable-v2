//
//  AuthService.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import Foundation
import Supabase

protocol AuthServicing {
    func signIn(email: String, password: String) async throws -> AppUser
    func signUp(email: String, password: String, role: UserRole) async throws -> AppUser
    func signOut() async throws
    func currentUserId() -> String?
}

class AuthService: AuthServicing {
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }
    
    func signIn(email: String, password: String) async throws -> AppUser {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        
        // Fetch user data from your users table
        let userId = session.user.id.uuidString
        let user: AppUser = try await client.database
            .from("users")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        return user
    }
    
    func signUp(email: String, password: String, role: UserRole) async throws -> AppUser {
        let session = try await client.auth.signUp(
            email: email,
            password: password
        )
        
        let userId = session.user.id.uuidString
        
        // Create user record in your users table
        let newUser = AppUser(
            id: userId,
            email: email,
            role: role,
            createdAt: Date()
        )
        
        try await client.database
            .from("users")
            .insert(newUser)
            .execute()
        
        return newUser
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func currentUserId() -> String? {
        return client.auth.currentSession?.user.id.uuidString
    }
}

