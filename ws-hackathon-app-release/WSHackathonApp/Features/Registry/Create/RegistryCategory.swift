//
//  RegistryCategory.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 17/05/26.
//

import Foundation

struct RegistryCategory: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var isCustom: Bool
    
    static func == (lhs: RegistryCategory, rhs: RegistryCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Predefined categories as static instances
extension RegistryCategory {
    static let kitchen    = RegistryCategory(id: UUID(), name: "Kitchen & Cookware", isCustom: false)
    static let dining     = RegistryCategory(id: UUID(), name: "Dining & Entertaining", isCustom: false)
    static let electrics  = RegistryCategory(id: UUID(), name: "Electrics & Appliances", isCustom: false)
    static let outdoor    = RegistryCategory(id: UUID(), name: "Outdoor & Garden", isCustom: false)
    static let bar        = RegistryCategory(id: UUID(), name: "Bar & Wine", isCustom: false)
    static let storage    = RegistryCategory(id: UUID(), name: "Storage & Organization", isCustom: false)
    static let general    = RegistryCategory(id: UUID(), name: "General", isCustom: false)
    
    static var predefined: [RegistryCategory] {
        [.kitchen, .dining, .electrics, .outdoor, .bar, .storage, .general]
    }
    
    static func matchingCategory(for pattern: String?) -> RegistryCategory? {
        guard let pattern = pattern?.lowercased() else { return nil }
        if pattern.contains("cookware") || pattern.contains("cutlery") 
            || pattern.contains("food") { return .kitchen }
        if pattern.contains("tabletop") || pattern.contains("glassware") 
            || pattern.contains("bar") { return .dining }
        if pattern.contains("electrics") { return .electrics }
        if pattern.contains("outdoor") { return .outdoor }
        if pattern.contains("homekeeping") { return .storage }
        return nil
    }
}
