//
//  RegistryInstructions.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 05/04/26.
//

import Foundation

struct RegistryInstruction: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let detailedTitle: String
    let detailedDescription: String
}

struct RegistryStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let description: String
}
