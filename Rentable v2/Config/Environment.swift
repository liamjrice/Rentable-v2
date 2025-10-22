//
//  Environment.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import Foundation

/// App environment configuration
enum Environment {
    case development
    case staging
    case production
    
    // MARK: - Current Environment
    
    /// Returns the current environment based on build configuration
    static var current: Environment {
        #if DEBUG
        return .development
        #elseif STAGING
        return .staging
        #else
        return .production
        #endif
    }
    
    // MARK: - Environment Properties
    
    /// Display name for the environment
    var displayName: String {
        switch self {
        case .development:
            return "Development"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }
    
    /// Whether debug features should be enabled
    var isDebugEnabled: Bool {
        switch self {
        case .development, .staging:
            return true
        case .production:
            return false
        }
    }
    
    /// Whether to show environment badge in UI
    var showEnvironmentBadge: Bool {
        return self != .production
    }
    
    // MARK: - Supabase Configuration
    
    /// Supabase project URL
    var supabaseURL: String {
        switch self {
        case .development:
            // Use the same URL for now, can be different if needed
            return "https://chiiqjwlhwnchkaygivx.supabase.co"
        case .staging:
            // Add staging URL when available
            return "https://chiiqjwlhwnchkaygivx.supabase.co"
        case .production:
            return "https://chiiqjwlhwnchkaygivx.supabase.co"
        }
    }
    
    /// Supabase anonymous key
    var supabaseAnonKey: String {
        switch self {
        case .development:
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoaWlxandsaHduY2hrYXlnaXZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NTk4NDMsImV4cCI6MjA3NjIzNTg0M30.2fpKvEaCHzExjg_I1JudBKtsDuaXeOnjouhXARJWJZk"
        case .staging:
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoaWlxandsaHduY2hrYXlnaXZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NTk4NDMsImV4cCI6MjA3NjIzNTg0M30.2fpKvEaCHzExjg_I1JudBKtsDuaXeOnjouhXARJWJZk"
        case .production:
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoaWlxandsaHduY2hrYXlnaXZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NTk4NDMsImV4cCI6MjA3NjIzNTg0M30.2fpKvEaCHzExjg_I1JudBKtsDuaXeOnjouhXARJWJZk"
        }
    }
    
    // MARK: - API Configuration
    
    /// API request timeout in seconds
    var apiTimeout: TimeInterval {
        switch self {
        case .development:
            return 60.0 // Longer timeout for debugging
        case .staging:
            return 30.0
        case .production:
            return 30.0
        }
    }
    
    /// Whether to log network requests
    var shouldLogNetworkRequests: Bool {
        return isDebugEnabled
    }
    
    // MARK: - Feature Flags
    
    /// Whether to enable analytics
    var analyticsEnabled: Bool {
        return self == .production
    }
    
    /// Whether to enable crash reporting
    var crashReportingEnabled: Bool {
        return self != .development
    }
}

// MARK: - Environment Badge View

#if DEBUG
import SwiftUI

/// Debug badge showing current environment
struct EnvironmentBadge: View {
    let environment: Environment
    
    var body: some View {
        if environment.showEnvironmentBadge {
            Text(environment.displayName.uppercased())
                .font(.caption2.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(badgeColor)
                .cornerRadius(4)
                .shadow(radius: 2)
        }
    }
    
    private var badgeColor: Color {
        switch environment {
        case .development:
            return .green
        case .staging:
            return .orange
        case .production:
            return .red
        }
    }
}
#endif

