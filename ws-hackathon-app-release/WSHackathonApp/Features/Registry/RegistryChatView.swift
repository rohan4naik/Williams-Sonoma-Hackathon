//
//  RegistryChatView.swift
//  WSHackathonApp
//

import SwiftUI

struct RegistryChatView: View {
    let registryId: UUID
    let registryName: String
    
    @EnvironmentObject var collabManager: CollaborationManager
    @EnvironmentObject var mockUserManager: MockUserManager
    @EnvironmentObject var registryRepo: RegistryRepository
    @Environment(\.dismiss) var dismiss
    
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    private var messages: [RegistryChatMessage] {
        collabManager.messages(for: registryId)
    }
    
    private var currentUserName: String {
        mockUserManager.currentUser.name
    }
    
    // Participants: owner + collaborators
    private var participantNames: [String] {
        let collabs = collabManager.collaborators(for: registryId).map { $0.name }
        // Find owner name
        let allMockUsers: [MockUser] = [.alice, .bob, .carol]
        var ownerName = "Owner"
        for (userId, registries) in registryRepo.allUserRegistries {
            if registries.contains(where: { $0.id == registryId }) {
                ownerName = allMockUsers.first { $0.id == userId }?.name ?? "Owner"
                break
            }
        }
        if registryRepo.registries.contains(where: { $0.id == registryId }) {
            ownerName = mockUserManager.currentUser.name
        }
        return ([ownerName] + collabs).filter { !$0.isEmpty }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Participants bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(participantNames, id: \.self) { name in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text(String(name.prefix(1)))
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                Text(name.components(separatedBy: " ").first ?? name)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background(Color.white)
                
                Divider()
                
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            if messages.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary)
                                    Text("No messages yet")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Start chatting with your registry collaborators.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 60)
                            } else {
                                ForEach(messages) { message in
                                    ChatMessageRow(
                                        message: message,
                                        currentUserName: currentUserName
                                    )
                                    .id(message.id)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .background(Color(.systemGray6))
                    .onAppear {
                        scrollProxy = proxy
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: messages.count) { _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Input bar
                HStack(spacing: 12) {
                    TextField("Message...", text: $messageText, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.isEmpty ? .gray : .black)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
            }
            .navigationTitle(registryName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        collabManager.sendMessage(
            registryId: registryId,
            senderName: currentUserName,
            content: trimmed
        )
        messageText = ""
    }
}

// MARK: - Message Row
struct ChatMessageRow: View {
    let message: RegistryChatMessage
    let currentUserName: String
    
    private var isCurrentUser: Bool {
        message.senderName == currentUserName
    }
    
    private var isSystem: Bool {
        message.type == .system
    }
    
    var body: some View {
        if isSystem {
            // System message — centered, small, gray
            HStack {
                Spacer()
                Text(message.content)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)
                Spacer()
            }
            .padding(.vertical, 4)
        } else {
            // User message — bubble style
            HStack(alignment: .bottom, spacing: 8) {
                if isCurrentUser { Spacer() }
                
                if !isCurrentUser {
                    // Avatar
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text(String(message.senderName.prefix(1)))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.black)
                        )
                }
                
                VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                    if !isCurrentUser {
                        Text(message.senderName.components(separatedBy: " ").first ?? message.senderName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }
                    
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(isCurrentUser ? .white : .black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isCurrentUser ? Color.black : Color.white)
                        .chatCornerRadius(18, corners: isCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                    
                    Text(message.timestamp.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
                
                if !isCurrentUser { Spacer() }
            }
        }
    }
}

// MARK: - Safe Conflict-Free Corner Radius Helper
fileprivate extension View {
    func chatCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(ChatRoundedCorner(radius: radius, corners: corners))
    }
}

fileprivate struct ChatRoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
