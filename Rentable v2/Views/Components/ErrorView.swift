//
//  ErrorView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI

/// Reusable error view component
struct ErrorView: View {
    
    // MARK: - Properties
    
    var message: String
    var type: ErrorType = .error
    var retryAction: (() -> Void)? = nil
    
    // MARK: - Error Type
    
    enum ErrorType {
        case error      // Red, critical errors
        case warning    // Orange, warnings
        case info       // Blue, informational
        
        var color: Color {
            switch self {
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .error: return "exclamationmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                    .font(.title2)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding()
            .background(type.color.opacity(0.1))
            .cornerRadius(12)
            
            if let retry = retryAction {
                Button(action: retry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(type == .error ? "Error" : type == .warning ? "Warning" : "Information"): \(message)")
    }
}

// MARK: - Inline Error View

struct InlineErrorView: View {
    var message: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
                .font(.caption)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}

// MARK: - Preview

#Preview("Error") {
    ErrorView(
        message: "Unable to connect to the server. Please check your internet connection.",
        type: .error,
        retryAction: { print("Retry tapped") }
    )
    .padding()
}

#Preview("Warning") {
    ErrorView(
        message: "Your session will expire soon. Please save your work.",
        type: .warning
    )
    .padding()
}

#Preview("Info") {
    ErrorView(
        message: "New features are available. Update to get the latest improvements.",
        type: .info
    )
    .padding()
}

#Preview("Inline") {
    InlineErrorView(message: "Please enter a valid email address")
        .padding()
}

