//
//  CollaborationManager.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import Foundation
import Combine
import UserNotifications

@MainActor
final class CollaborationManager: ObservableObject {
    static let shared = CollaborationManager()
    
    // Current user identity (simulated)
    @Published var currentUserName: String = "Alice Johnson"
    
    // registryId → [Collaborator]
    @Published var collaborators: [UUID: [Collaborator]] = [:]
    
    // All pending/processed requests
    @Published var requests: [CollabRequest] = []
    
    // All contributions across all registries
    @Published var contributions: [Contribution] = []
    
    // registryId → shareToken (first 8 chars of UUID string)
    @Published var shareTokens: [UUID: String] = [:]
    
    // registryId → [RegistryChatMessage]
    @Published var chatMessages: [UUID: [RegistryChatMessage]] = [:]
    
    private init() {}
    
    func switchUser(to user: MockUser) {
        currentUserName = user.name
    }
    
    func joinedRegistries(
        for userName: String,
        in registryRepo: RegistryRepository
    ) -> [Registry] {
        // Find all registryIds where userName is a collaborator
        let joinedIds = collaborators
            .filter { $0.value.contains { $0.name == userName } }
            .map { $0.key }
        
        // Search across all users' registries (excluding active user's entry in allUserRegistries)
        let otherUsersRegistries = registryRepo.allUserRegistries
            .filter { $0.key != registryRepo.currentUserId }
            .values.flatMap { $0 }
        let allRegistries = otherUsersRegistries + registryRepo.registries
        
        // Deduplicate and return matches
        let unique = Array(Set(allRegistries.map { $0.id }))
            .compactMap { id in allRegistries.first { $0.id == id } }
        
        return unique.filter { joinedIds.contains($0.id) }
    }
    
    // MARK: - Share Token
    
    func generateToken(for registryId: UUID) -> String {
        if let existing = shareTokens[registryId] { return existing }
        let token = String(registryId.uuidString.prefix(8)).uppercased()
        shareTokens[registryId] = token
        return token
    }
    
    func registry(for token: String, in registryRepo: RegistryRepository) -> Registry? {
        guard let registryId = shareTokens.first(where: { 
            $0.value == token.uppercased() 
        })?.key else { return nil }
        
        // Search across ALL users' registries (excluding active user's entry in allUserRegistries)
        let otherUsersRegistries = registryRepo.allUserRegistries
            .filter { $0.key != registryRepo.currentUserId }
            .values.flatMap { $0 }
        let allRegistries = otherUsersRegistries + registryRepo.registries
        return allRegistries.first { $0.id == registryId }
    }
    
    // MARK: - Helpers
    
    func ownerName(for registryId: UUID, in registryRepo: RegistryRepository) -> String {
        let allMockUsers: [MockUser] = [.alice, .bob, .carol]
        for (userId, registries) in registryRepo.allUserRegistries {
            if registries.contains(where: { $0.id == registryId }) {
                return allMockUsers.first { $0.id == userId }?.name ?? "Owner"
            }
        }
        if registryRepo.registries.contains(where: { $0.id == registryId }) {
            return allMockUsers.first { $0.id == registryRepo.currentUserId }?.name ?? "Owner"
        }
        return "Owner"
    }
    
    // MARK: - Collaborators
    
    func addCollaborator(name: String, 
                         permission: CollabPermission = .limited, 
                         to registryId: UUID,
                         registryRepo: RegistryRepository) {
        let collaborator = Collaborator(
            id: UUID(),
            name: name,
            joinedAt: Date(),
            permission: permission
        )
        if collaborators[registryId] == nil {
            collaborators[registryId] = []
        }
        collaborators[registryId]?.append(collaborator)
        
        let owner = ownerName(for: registryId, in: registryRepo)
        sendNotification(
            title: "New Collaborator",
            body: "[For \(owner)] \(name) joined your registry!"
        )
        
        sendSystemMessage(
            registryId: registryId,
            content: "👋 \(name) joined the registry as a collaborator."
        )
    }
    
    func collaborators(for registryId: UUID) -> [Collaborator] {
        collaborators[registryId] ?? []
    }
    
    func removeCollaborator(id: UUID, from registryId: UUID) {
        collaborators[registryId]?.removeAll { $0.id == id }
    }
    
    func updatePermission(_ permission: CollabPermission, for collaboratorId: UUID, in registryId: UUID) {
        guard let index = collaborators[registryId]?.firstIndex(where: { $0.id == collaboratorId }) else { return }
        collaborators[registryId]?[index].permission = permission
    }
    
    // MARK: - Requests
    
    func submitRequest(
        registryId: UUID,
        collaboratorName: String,
        action: CollabAction,
        permission: CollabPermission,
        registryRepo: RegistryRepository
    ) {
        if permission == .full {
            // Execute immediately
            switch action {
            case .add(let item):
                registryRepo.addProduct(item, to: registryId)
            case .remove(let itemId, _):
                registryRepo.removeProduct(productId: itemId, from: registryId)
            }
            return
        }
        
        // Admin controlled — create pending request
        let collaboratorId = collaborators[registryId]?.first { 
            $0.name == collaboratorName 
        }?.id ?? UUID()
        
        let request = CollabRequest(
            id: UUID(),
            registryId: registryId,
            collaboratorId: collaboratorId,
            collaboratorName: collaboratorName,
            action: action,
            status: .pending,
            createdAt: Date()
        )
        requests.append(request)
        
        // Notify owner
        let actionText: String
        switch action {
        case .add(let item): actionText = "add \(item.title)"
        case .remove(_, let title): actionText = "remove \(title)"
        }
        
        let owner = ownerName(for: registryId, in: registryRepo)
        sendNotification(
            title: "Registry Request",
            body: "[For \(owner)] \(collaboratorName) wants to \(actionText)"
        )
        
        switch action {
        case .add(let item):
            sendSystemMessage(
                registryId: registryId,
                content: "🔔 \(collaboratorName) requested to add \(item.title). Awaiting owner approval."
            )
        case .remove(_, let title):
            sendSystemMessage(
                registryId: registryId,
                content: "🔔 \(collaboratorName) requested to remove \(title). Awaiting owner approval."
            )
        }
    }
    
    func approveRequest(id: UUID, registryRepo: RegistryRepository) {
        guard let index = requests.firstIndex(where: { $0.id == id }) else { return }
        requests[index].status = .approved
        let request = requests[index]
        
        switch request.action {
        case .add(let item):
            registryRepo.addProduct(item, to: request.registryId)
            sendSystemMessage(
                registryId: request.registryId,
                content: "✅ \(request.collaboratorName)'s request to add \(item.title) was approved."
            )
        case .remove(let itemId, let title):
            registryRepo.removeProduct(productId: itemId, from: request.registryId)
            sendSystemMessage(
                registryId: request.registryId,
                content: "✅ \(request.collaboratorName)'s request to remove \(title) was approved."
            )
        }
    }
    
    func rejectRequest(id: UUID) {
        guard let index = requests.firstIndex(where: { $0.id == id }) else { return }
        requests[index].status = .rejected
        let req = requests[index]
        
        switch req.action {
        case .add(let item):
            sendSystemMessage(
                registryId: req.registryId,
                content: "❌ \(req.collaboratorName)'s request to add \(item.title) was declined."
            )
        case .remove(_, let title):
            sendSystemMessage(
                registryId: req.registryId,
                content: "❌ \(req.collaboratorName)'s request to remove \(title) was declined."
            )
        }
    }
    
    func pendingRequests(for registryId: UUID) -> [CollabRequest] {
        requests.filter { $0.registryId == registryId && $0.status == .pending }
    }
    
    // MARK: - Group Chat
    
    func sendMessage(registryId: UUID, senderName: String, content: String) {
        let message = RegistryChatMessage(
            registryId: registryId,
            senderName: senderName,
            content: content,
            type: .user
        )
        appendMessage(message, to: registryId)
    }
    
    func sendSystemMessage(registryId: UUID, content: String) {
        let message = RegistryChatMessage(
            registryId: registryId,
            senderName: "System",
            content: content,
            type: .system
        )
        appendMessage(message, to: registryId)
    }
    
    private func appendMessage(_ message: RegistryChatMessage, to registryId: UUID) {
        if chatMessages[registryId] == nil {
            chatMessages[registryId] = []
        }
        chatMessages[registryId]?.append(message)
    }
    
    func messages(for registryId: UUID) -> [RegistryChatMessage] {
        chatMessages[registryId] ?? []
    }
    
    // MARK: - Contributions
    
    func addContribution(
        registryId: UUID,
        itemId: String,
        itemTitle: String,
        contributorName: String,
        amount: Double,
        isFullPayment: Bool,
        registryRepo: RegistryRepository
    ) {
        let contribution = Contribution(
            id: UUID(),
            registryId: registryId,
            itemId: itemId,
            itemTitle: itemTitle,
            contributorName: contributorName,
            amount: amount,
            isFullPayment: isFullPayment,
            date: Date()
        )
        contributions.append(contribution)
        
        let owner = ownerName(for: registryId, in: registryRepo)
        let amountText = amount.formatted(.currency(code: "USD"))
        
        // 1. Send local system notification
        sendNotification(
            title: "New Contribution",
            body: "[For \(owner)] \(contributorName) contributed \(amountText) for \(itemTitle)!"
        )
        
        // 2. Post to registry group chat
        let messageText = isFullPayment ?
            "🎁 \(contributorName) gifted \(itemTitle) in full!" :
            "💸 \(contributorName) contributed \(amountText) for \(itemTitle)!"
        sendSystemMessage(registryId: registryId, content: messageText)
    }
    
    func contributions(for itemId: String, in registryId: UUID) -> [Contribution] {
        contributions.filter { $0.itemId == itemId && $0.registryId == registryId }
    }
    
    // MARK: - Local Notifications
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
