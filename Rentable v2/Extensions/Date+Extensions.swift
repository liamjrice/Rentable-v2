//
//  Date+Extensions.swift
//  Rentable v2
//
//  Created by Liam Rice on 22/10/2025.
//

import Foundation

extension Date {
    
    // MARK: - Age Calculation
    
    /// Calculates age in years from the date
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: self, to: Date())
        return ageComponents.year ?? 0
    }
    
    /// Checks if person is 18 or older
    var isAdult: Bool {
        return age >= 18
    }
    
    // MARK: - Formatting
    
    /// Returns formatted date string (e.g., "January 15, 2000")
    var formattedLong: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: self)
    }
    
    /// Returns formatted date string (e.g., "Jan 15, 2000")
    var formattedMedium: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    /// Returns formatted date string (e.g., "1/15/00")
    var formattedShort: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
    // MARK: - Date Manipulation
    
    /// Returns date with added/subtracted years
    func adding(years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }
    
    /// Returns date with added/subtracted months
    func adding(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    /// Returns date with added/subtracted days
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    // MARK: - Helpers
    
    /// Returns the start of the day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Returns the end of the day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
}

