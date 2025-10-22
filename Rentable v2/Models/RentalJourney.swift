//
//  RentalJourney.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import Foundation

enum JourneyStage: String, CaseIterable {
    case searching = "Searching"
    case viewing = "Viewing"
    case applying = "Application"
    case contractReview = "Contract Review"
    case signing = "Signing"
    case moveIn = "Move In"
    
    var icon: String {
        switch self {
        case .searching: return "magnifyingglass"
        case .viewing: return "eye"
        case .applying: return "doc.text"
        case .contractReview: return "doc.text.magnifyingglass"
        case .signing: return "signature"
        case .moveIn: return "key.fill"
        }
    }
    
    var description: String {
        switch self {
        case .searching: return "Finding your perfect place"
        case .viewing: return "Scheduling property tours"
        case .applying: return "Submitting your application"
        case .contractReview: return "Reviewing rental agreement"
        case .signing: return "Finalizing documents"
        case .moveIn: return "Getting ready to move"
        }
    }
}

struct RentalJourney: Identifiable {
    let id: String
    let propertyTitle: String
    let propertyAddress: String
    let currentStage: JourneyStage
    let monthlyRent: Decimal
    let landlordName: String
    let startedAt: Date
    let estimatedMoveInDate: Date?
    let tasks: [JourneyTask]
    
    var progress: Double {
        let allStages = JourneyStage.allCases
        guard let currentIndex = allStages.firstIndex(of: currentStage) else { return 0 }
        return Double(currentIndex + 1) / Double(allStages.count)
    }
    
    var completedStages: [JourneyStage] {
        let allStages = JourneyStage.allCases
        guard let currentIndex = allStages.firstIndex(of: currentStage) else { return [] }
        return Array(allStages.prefix(currentIndex))
    }
}

struct JourneyTask: Identifiable {
    let id: String
    let title: String
    let description: String
    let isCompleted: Bool
    let dueDate: Date?
    let priority: TaskPriority
    
    enum TaskPriority {
        case high
        case medium
        case low
        
        var color: String {
            switch self {
            case .high: return "systemRed"
            case .medium: return "systemOrange"
            case .low: return "systemGray"
            }
        }
    }
}

