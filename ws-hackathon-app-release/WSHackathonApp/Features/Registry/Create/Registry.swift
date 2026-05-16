//
//  Registry.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
struct Registry: Identifiable {
    let id: UUID
    let firstName: String
    let lastName: String
    let event: RegistryEvent
    let customTitle: String?
    let date: Date
    let imageData: Data?
    var items: [RegistryItem]
    
    var displayName: String {
        let eventName = (event == .other && !(customTitle?.isEmpty ?? true)) ? customTitle! : event.title
        return "\(firstName) \(lastName) - \(eventName)"
    }
}
