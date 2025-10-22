//
//  String+Validation.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import Foundation

extension String {
    
    // MARK: - Email Validation
    
    /// Validates email format using regex
    var isValidEmail: Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    // MARK: - Phone Validation
    
    /// Validates UK mobile phone number
    var isValidUKPhone: Bool {
        // UK mobile number: 07XXX XXX XXX or 07XXXXXXXXX
        let phoneRegex = "^07\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        let cleanedPhone = self.replacingOccurrences(of: " ", with: "")
        return phonePredicate.evaluate(with: cleanedPhone)
    }
    
    /// Formats UK phone number as 07XXX XXX XXX
    var formattedUKPhone: String {
        let cleaned = self.replacingOccurrences(of: " ", with: "")
        guard cleaned.count == 11 else { return cleaned }
        
        let index1 = cleaned.index(cleaned.startIndex, offsetBy: 5)
        let index2 = cleaned.index(cleaned.startIndex, offsetBy: 8)
        return "\(cleaned[..<index1]) \(cleaned[index1..<index2]) \(cleaned[index2...])"
    }
    
    // MARK: - Postcode Validation
    
    /// Validates UK postcode format
    var isValidUKPostcode: Bool {
        // UK postcode: SW1A 1AA, EC1A 1BB, etc.
        let postcodeRegex = "^[A-Z]{1,2}\\d{1,2}[A-Z]?\\s?\\d[A-Z]{2}$"
        let postcodePredicate = NSPredicate(format: "SELF MATCHES %@", postcodeRegex)
        let cleanedPostcode = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return postcodePredicate.evaluate(with: cleanedPostcode)
    }
    
    // MARK: - Password Validation
    
    /// Validates password strength (min 8 chars, letter + number)
    var isStrongPassword: Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*#?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: self)
    }
    
    /// Returns password strength level
    var passwordStrength: PasswordStrength {
        if self.count < 6 {
            return .weak
        } else if self.count < 8 {
            return .fair
        } else if isStrongPassword {
            if self.count >= 12 && containsSpecialCharacter && containsUppercase && containsLowercase {
                return .veryStrong
            }
            return .strong
        }
        return .fair
    }
    
    enum PasswordStrength {
        case weak, fair, strong, veryStrong
        
        var color: String {
            switch self {
            case .weak: return "red"
            case .fair: return "orange"
            case .strong: return "green"
            case .veryStrong: return "blue"
            }
        }
        
        var label: String {
            switch self {
            case .weak: return "Weak"
            case .fair: return "Fair"
            case .strong: return "Strong"
            case .veryStrong: return "Very Strong"
            }
        }
    }
    
    private var containsSpecialCharacter: Bool {
        let specialCharacters = CharacterSet(charactersIn: "@$!%*#?&")
        return self.rangeOfCharacter(from: specialCharacters) != nil
    }
    
    private var containsUppercase: Bool {
        return self.rangeOfCharacter(from: .uppercaseLetters) != nil
    }
    
    private var containsLowercase: Bool {
        return self.rangeOfCharacter(from: .lowercaseLetters) != nil
    }
    
    // MARK: - Name Validation
    
    /// Validates name (min 2 characters)
    var isValidName: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2
    }
    
    // MARK: - Sanitization
    
    /// Returns only numeric characters
    var digitsOnly: String {
        return self.filter { $0.isNumber }
    }
    
    /// Returns only alphanumeric characters
    var alphanumericOnly: String {
        return self.filter { $0.isLetter || $0.isNumber }
    }
}

