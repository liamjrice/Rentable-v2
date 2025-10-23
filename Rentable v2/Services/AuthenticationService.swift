//
//  AuthenticationService.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import Foundation
import UIKit
import Supabase

// MARK: - AuthError

enum AuthError: LocalizedError {
    case emailAlreadyExists
    case invalidCredentials
    case emailNotVerified
    case userNotFound
    case networkError
    case invalidData
    case uploadFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyExists:
            return "This email is already registered. Please sign in instead."
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .emailNotVerified:
            return "Please verify your email before signing in."
        case .userNotFound:
            return "User profile not found. Please contact support."
        case .networkError:
            return "Network connection error. Please check your internet connection."
        case .invalidData:
            return "Invalid data received. Please try again."
        case .uploadFailed:
            return "Failed to upload profile image. Please try again."
        case .unknown(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}

// MARK: - AuthenticationService

/// Thread-safe authentication service using actor pattern
actor AuthenticationService {
    
    // MARK: - Singleton
    static let shared = AuthenticationService()
    
    // MARK: - Properties
    private let client: SupabaseClient
    
    // MARK: - Initialization
    
    private init(client: SupabaseClient = SupabaseManager.shared.client) {
        self.client = client
    }
    
    // MARK: - Public Methods
    
    /// Checks if an email already exists in the system
    /// - Parameter email: The email to check
    /// - Returns: True if email exists, false otherwise
    func checkEmailExists(email: String) async throws -> Bool {
        do {
            // Query the profiles table for the email
            let response: [User] = try await client
                .from("profiles")
                .select()
                .eq("email", value: email)
                .execute()
                .value
            
            return !response.isEmpty
        } catch {
            throw AuthError.networkError
        }
    }
    
   /// Signs in a user with email and password
/// - Parameters:
///   - email: User's email
///   - password: User's password
/// - Returns: Authenticated user with profile data
func signIn(email: String, password: String) async throws -> User {
    do {
        // Authenticate with Supabase
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )

        // Check if email is confirmed
        if session.user.emailConfirmedAt == nil {
            throw AuthError.emailNotVerified
        }

        // Fetch user profile from database after successful auth
        let userId = session.user.id
        let user: User = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        return user

    } catch let error as AuthError {
        throw error
    } catch {
        // Map Supabase errors to user-friendly messages
        let errorDesc = error.localizedDescription.lowercased()
        if errorDesc.contains("invalid login") || errorDesc.contains("invalid credentials") {
            throw AuthError.invalidCredentials
        } else if errorDesc.contains("email not confirmed") || errorDesc.contains("not verified") {
            throw AuthError.emailNotVerified
        } else if errorDesc.contains("network") || errorDesc.contains("connection") {
            throw AuthError.networkError
        } else if errorDesc.contains("not found") {
            throw AuthError.userNotFound
        } else {
            throw AuthError.unknown(error)
        }
    }
}
    
    /// Signs up a new user
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    ///   - userData: User profile data
    /// - Returns: Void (verification email is sent; session may be nil until verified)
    /// - Note: Supabase auto-sends verification email. Profile will be created after OTP verification when a session exists.
    func signUp(email: String, password: String, userData: User) async throws {
        do {
            // Request signup (verification email is sent automatically by Supabase)
            _ = try await client.auth.signUp(
                email: email,
                password: password
            )
        } catch let error as AuthError {
            throw error
        } catch {
            // Map Supabase errors to user-friendly messages
            let errorDesc = error.localizedDescription.lowercased()
            if errorDesc.contains("already registered") || errorDesc.contains("already exists") {
                throw AuthError.emailAlreadyExists
            } else if errorDesc.contains("network") || errorDesc.contains("connection") {
                throw AuthError.networkError
            } else {
                throw AuthError.unknown(error)
            }
        }
    }
    
    /// Verifies OTP code sent to email
    /// - Parameters:
    ///   - email: User's email
    ///   - code: OTP code
    /// - Returns: User profile after successful verification
    /// - Note: On success, session is automatically created by Supabase
    func verifyOTP(email: String, code: String) async throws -> User {
        do {
            // Verify OTP - session is automatically created on success
            let session = try await client.auth.verifyOTP(
                email: email,
                token: code,
                type: .signup
            )

            let userId = session.user.id

            // Ensure a profile row exists now that we have a session
            struct NewProfileMinimal: Encodable {
                let id: UUID
                let email: String
                let user_type: String
                let created_at: Date
            }
            let minimal = NewProfileMinimal(
                id: userId,
                email: email,
                user_type: "tenant",
                created_at: Date()
            )
            // Try insert; if it already exists, ignore error
            do {
                _ = try await client
                    .from("profiles")
                    .insert(minimal)
                    .execute()
            } catch {
                // Ignore conflict/duplicate insert errors
            }

            // Fetch and return user profile
            let user: User = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value

            return user

        } catch {
            let errorDesc = error.localizedDescription.lowercased()
            if errorDesc.contains("invalid") || errorDesc.contains("expired") {
                throw AuthError.invalidCredentials
            } else if errorDesc.contains("network") || errorDesc.contains("connection") {
                throw AuthError.networkError
            } else {
                throw AuthError.unknown(error)
            }
        }
    }
    
    /// Uploads a profile image to Supabase storage
    /// - Parameters:
    ///   - userId: User's UUID
    ///   - image: UIImage to upload
    /// - Returns: Public URL of uploaded image
    func uploadProfileImage(userId: UUID, image: UIImage) async throws -> String {
        do {
            // Compress UIImage to JPEG with 0.7 quality
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                throw AuthError.uploadFailed
            }

            // Ensure image is within size limit (max 1MB)
            guard imageData.count <= 1_048_576 else {
                throw AuthError.uploadFailed
            }

            // Generate unique filename: userId/profile.jpg
            let fileName = "\(userId.uuidString)/profile.jpg"

            // Upload to storage
            try await client.storage
                .from("avatars")
                .upload(
                    path: fileName,
                    file: imageData,
                    options: FileOptions(
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )

            // Get public URL
            let publicURL = try client.storage
                .from("avatars")
                .getPublicURL(path: fileName)

            // Update profiles table with image URL
            try await client
                .from("profiles")
                .update(["profile_image_url": publicURL.absoluteString])
                .eq("id", value: userId.uuidString)
                .execute()

            return publicURL.absoluteString

        } catch let error as AuthError {
            throw error
        } catch {
            let desc = error.localizedDescription.lowercased()
            if desc.contains("network") || desc.contains("connection") {
                throw AuthError.networkError
            } else {
                throw AuthError.uploadFailed
            }
        }
    }
    
    /// Uploads profile image data (alternative method accepting Data)
    /// - Parameters:
    ///   - userId: User's UUID
    ///   - imageData: Pre-compressed image data
    /// - Returns: Public URL of uploaded image
    func uploadProfileImageData(userId: UUID, imageData: Data) async throws -> String {
        do {
            // Ensure image is within size limit (1MB)
            guard imageData.count <= 1_048_576 else {
                throw AuthError.uploadFailed
            }

            let fileName = "\(userId.uuidString)/profile.jpg"

            // Upload to storage
            try await client.storage
                .from("avatars")
                .upload(
                    path: fileName,
                    file: imageData,
                    options: FileOptions(
                        contentType: "image/jpeg",
                        upsert: true
                    )
                )

            // Get public URL
            let publicURL = try client.storage
                .from("avatars")
                .getPublicURL(path: fileName)

            // Update profiles table with image URL
            try await client
                .from("profiles")
                .update(["profile_image_url": publicURL.absoluteString])
                .eq("id", value: userId.uuidString)
                .execute()

            return publicURL.absoluteString

        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.uploadFailed
        }
    }

    /// Signs out the current user
    func signOut() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    /// Gets the current session
    /// - Returns: Current session if available
    func currentSession() async -> Session? {
        return client.auth.currentSession
    }
    
    /// Gets the current user ID
    /// - Returns: Current user's UUID if authenticated
    func currentUserId() async -> UUID? {
        return client.auth.currentSession?.user.id
    }
}

