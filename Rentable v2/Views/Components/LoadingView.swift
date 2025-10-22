//
//  LoadingView.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import SwiftUI

/// Reusable loading view component
struct LoadingView: View {
    
    // MARK: - Properties
    
    var message: String = "Loading..."
    var style: Style = .overlay
    
    // MARK: - Style Enum
    
    enum Style {
        case overlay        // Dark overlay with spinner
        case inline         // Inline spinner without overlay
        case blocking       // Full screen blocking
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            switch style {
            case .overlay:
                overlayStyle
            case .inline:
                inlineStyle
            case .blocking:
                blockingStyle
            }
        }
    }
    
    // MARK: - Style Variations
    
    private var overlayStyle: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(message)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .padding(24)
            .background(Color(.systemGray))
            .cornerRadius(16)
        }
    }
    
    private var inlineStyle: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var blockingStyle: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2.0)
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Preview

#Preview("Overlay") {
    ZStack {
        Color.gray
        LoadingView(message: "Signing in...", style: .overlay)
    }
}

#Preview("Inline") {
    LoadingView(message: "Loading...", style: .inline)
}

#Preview("Blocking") {
    LoadingView(message: "Please wait...", style: .blocking)
}

