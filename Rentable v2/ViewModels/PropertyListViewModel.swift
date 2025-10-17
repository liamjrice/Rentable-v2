//
//  PropertyListViewModel.swift
//  Rentable v2
//
//  Created by Liam Rice on 17/10/2025.
//

import Foundation
import Combine

@MainActor
final class PropertyListViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let propertyService: PropertyServicing
    
    init(propertyService: PropertyServicing = PropertyService()) {
        self.propertyService = propertyService
    }
    
    func load() async {
        isLoading = true
        error = nil
        
        do {
            let fetchedProperties = try await propertyService.fetchAll()
            self.properties = fetchedProperties
            print("✅ Loaded \(fetchedProperties.count) properties")
        } catch {
            self.error = error.localizedDescription
            print("❌ Failed to load properties: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await load()
    }
}

