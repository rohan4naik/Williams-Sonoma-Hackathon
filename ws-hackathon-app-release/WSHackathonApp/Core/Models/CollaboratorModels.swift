//
//  CollaboratorModels.swift
//  WSHackathonApp
//

import Foundation

enum CollabPermission: String, Codable {
    case full = "Full Access"
    case limited = "Limited"
}

struct Collaborator: Identifiable, Codable {
    let id: UUID
    let name: String
    let joinedAt: Date
    var permission: CollabPermission
}

enum CollabAction {
    case add(RegistryItem)
    case remove(itemId: String, itemTitle: String)
}

enum RequestStatus: String, Codable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}

struct CollabRequest: Identifiable {
    let id: UUID
    let registryId: UUID
    let collaboratorId: UUID
    let collaboratorName: String
    let action: CollabAction
    var status: RequestStatus
    let createdAt: Date
}

struct Contribution: Identifiable, Codable {
    let id: UUID
    let registryId: UUID
    let itemId: String
    let itemTitle: String
    let contributorName: String
    let amount: Double
    let isFullPayment: Bool
    let date: Date
}
