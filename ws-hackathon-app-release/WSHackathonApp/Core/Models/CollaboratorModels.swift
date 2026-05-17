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

enum MessageType {
    case user        // normal chat message from a participant
    case system      // auto-generated: request approved/rejected, collaborator joined, item added/removed
}

struct RegistryChatMessage: Identifiable {
    let id: UUID
    let registryId: UUID
    let senderName: String     // "Alice Johnson", "Bob Smith", or "System"
    let content: String
    let type: MessageType
    let timestamp: Date
    
    init(id: UUID = UUID(),
         registryId: UUID,
         senderName: String,
         content: String,
         type: MessageType = .user,
         timestamp: Date = Date()) {
        self.id = id
        self.registryId = registryId
        self.senderName = senderName
        self.content = content
        self.type = type
        self.timestamp = timestamp
    }
}
