//
//  Registry.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation

struct Registry: Identifiable, Hashable {
    let id: UUID
    let createdAt: Date
    let firstName: String
    let lastName: String
    let event: RegistryEvent
    let customTitle: String?
    let date: Date
    let imageData: Data?
    var items: [RegistryItem]
    
    init(id: UUID = UUID(),
         createdAt: Date = Date(),
         firstName: String,
         lastName: String,
         event: RegistryEvent,
         customTitle: String? = nil,
         date: Date,
         imageData: Data? = nil,
         items: [RegistryItem] = []) {
        self.id = id
        self.createdAt = createdAt
        self.firstName = firstName
        self.lastName = lastName
        self.event = event
        self.customTitle = customTitle
        self.date = date
        self.imageData = imageData
        self.items = items
    }
    
    var displayName: String {
        let eventName = (event == .other && !(customTitle?.isEmpty ?? true)) ? customTitle! : event.title
        return "\(firstName) \(lastName) - \(eventName)"
    }
    
    // MARK: - Hashable & Equality
    static func == (lhs: Registry, rhs: Registry) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
