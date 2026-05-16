//
//  RegistryEvent.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
enum RegistryEvent: String, CaseIterable, Identifiable {
    case birthday = "Birthday"
    case wedding = "Wedding"
    case anniversary = "Anniversary"
    case housewarming = "Housewarming"
    case other = "Other"
    
    var id: String { rawValue }
    var title: String { rawValue }
    
    var iconName: String {
        switch self {
        case .birthday: return "birthday.cake.fill"
        case .wedding: return "heart.fill"
        case .anniversary: return "sparkles"
        case .housewarming: return "house.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
