//
//  Constants.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import Foundation
import SwiftUI

/// App-wide constants
struct Constants {
    
    // MARK: - Validation
    
    struct Validation {
        /// Minimum length for user names
        static let minNameLength = 2
        
        /// Maximum length for user names
        static let maxNameLength = 50
        
        /// Minimum age requirement (18+)
        static let minAge = 18
        
        /// Maximum profile image size in bytes (1MB)
        static let maxImageSize = 1_048_576
        
        /// Minimum password length
        static let minPasswordLength = 8
        
        /// Maximum password length
        static let maxPasswordLength = 128
        
        /// OTP code length
        static let otpLength = 6
        
        /// Minimum address length
        static let minAddressLength = 5
        
        /// UK phone number length (without spaces)
        static let ukPhoneLength = 11
    }
    
    // MARK: - UI
    
    struct UI {
        /// Standard corner radius for cards and buttons
        static let cornerRadius: CGFloat = 12
        
        /// Small corner radius for smaller elements
        static let smallCornerRadius: CGFloat = 8
        
        /// Large corner radius for modals
        static let largeCornerRadius: CGFloat = 16
        
        /// Standard button height
        static let buttonHeight: CGFloat = 50
        
        /// Compact button height
        static let compactButtonHeight: CGFloat = 44
        
        /// Standard horizontal padding
        static let horizontalPadding: CGFloat = 20
        
        /// Standard vertical spacing
        static let verticalSpacing: CGFloat = 16
        
        /// Animation duration
        static let animationDuration: TimeInterval = 0.3
        
        /// Profile image size
        static let profileImageSize: CGFloat = 160
        
        /// Thumbnail image size
        static let thumbnailSize: CGFloat = 60
        
        /// Maximum image display size
        static let maxImageDisplaySize: CGFloat = 1000
    }
    
    // MARK: - Timing
    
    struct Timing {
        /// Resend OTP countdown in seconds
        static let resendOTPCountdown = 60
        
        /// Debounce delay for search/validation in seconds
        static let debounceDelay: TimeInterval = 0.3
        
        /// Session timeout in seconds (30 minutes)
        static let sessionTimeout: TimeInterval = 1800
        
        /// Auto-dismiss delay for success messages
        static let successMessageDuration: TimeInterval = 2.0
    }
    
    // MARK: - Regex Patterns
    
    struct Regex {
        /// Email validation pattern
        static let email = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        
        /// UK mobile phone pattern (07XXXXXXXXX)
        static let ukPhone = "^07\\d{9}$"
        
        /// UK postcode pattern
        static let ukPostcode = "^[A-Z]{1,2}\\d{1,2}[A-Z]?\\s?\\d[A-Z]{2}$"
        
        /// Password pattern (min 8 chars, letter + number)
        static let password = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{8,}$"
    }
    
    // MARK: - URLs
    
    struct URLs {
        /// Privacy policy URL
        static let privacyPolicy = "https://rentable.app/privacy"
        
        /// Terms of service URL
        static let termsOfService = "https://rentable.app/terms"
        
        /// Help center URL
        static let helpCenter = "https://rentable.app/help"
        
        /// Support email
        static let supportEmail = "support@rentable.app"
    }
    
    // MARK: - Storage Keys
    
    struct StorageKeys {
        /// Keychain keys
        struct Keychain {
            static let accessToken = "com.rentable.accessToken"
            static let refreshToken = "com.rentable.refreshToken"
            static let userId = "com.rentable.userId"
        }
        
        /// UserDefaults keys
        struct UserDefaults {
            static let hasCompletedOnboarding = "hasCompletedOnboarding"
            static let lastLoginDate = "lastLoginDate"
            static let selectedUserType = "selectedUserType"
        }
    }
    
    // MARK: - Limits
    
    struct Limits {
        /// Maximum number of properties per user
        static let maxPropertiesPerUser = 50
        
        /// Maximum number of images per property
        static let maxImagesPerProperty = 20
        
        /// Maximum description length
        static let maxDescriptionLength = 1000
    }
    
    // MARK: - Test Data
    
    struct TestData {
        /// Test OTP code for development
        static let testOTPCode = "123456"
        
        /// Test email for development
        static let testEmail = "test@rentable.app"
        
        /// Whether test data is enabled
        static var isEnabled: Bool {
            return Environment.current.isDebugEnabled
        }
    }
}

// MARK: - Color Constants

extension Constants {
    struct Colors {
        /// Primary brand color
        static let primary = Color.blue
        
        /// Secondary brand color
        static let secondary = Color.gray
        
        /// Success color
        static let success = Color.green
        
        /// Error color
        static let error = Color.red
        
        /// Warning color
        static let warning = Color.orange
        
        /// Info color
        static let info = Color.blue
    }
}

// MARK: - Font Constants

extension Constants {
    struct Fonts {
        /// Large title font
        static let largeTitle = Font.largeTitle.bold()
        
        /// Title font
        static let title = Font.title.bold()
        
        /// Headline font
        static let headline = Font.headline
        
        /// Body font
        static let body = Font.body
        
        /// Caption font
        static let caption = Font.caption
    }
}

