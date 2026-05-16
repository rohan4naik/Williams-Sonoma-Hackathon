//
//  CreateRegistryViewModel.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
import Combine

@MainActor
final class CreateRegistryViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var selectedEvent: RegistryEvent = .birthday
    @Published var date: Date = Date()
    @Published var customEventTitle: String = "" {
        didSet {
            if customEventTitle.count > 15 {
                customEventTitle = String(customEventTitle.prefix(15))
            }
        }
    }
    @Published var customEventDescription: String = "" {
        didSet {
            if customEventDescription.count > 70 {
                customEventDescription = String(customEventDescription.prefix(70))
            }
        }
    }
    
    var isValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty
    }
}
