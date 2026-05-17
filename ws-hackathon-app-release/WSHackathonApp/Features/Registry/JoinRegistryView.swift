//
//  JoinRegistryView.swift
//  WSHackathonApp
//

import SwiftUI

struct JoinRegistryView: View {
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var collabManager: CollaborationManager
    @EnvironmentObject var mockUserManager: MockUserManager
    @Environment(\.dismiss) var dismiss
    
    @State private var token = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var joinedRegistryName = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "link.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.black)
                        Text("Join a Registry")
                            .font(.title2.bold())
                        Text("Enter the invite code or link shared by the registry owner.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 8)
                    
                    // Joining User Indicator Card
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text(mockUserManager.currentUser.avatarInitials)
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Joining as")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(mockUserManager.currentUser.name)
                                .font(.subheadline.bold())
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Token field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Invite Code or Link")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g. ws://registry/A1B2C3D4", text: $token)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                    }
                    
                    // Join button
                    Button(action: joinRegistry) {
                        Text("Join Registry")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canJoin ? Color.black : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(!canJoin)
                }
                .padding(24)
            }
            .navigationTitle("Join Registry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Joined!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("You've joined \(joinedRegistryName) as a collaborator.")
            }
        }
    }
    
    private var canJoin: Bool {
        !token.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func joinRegistry() {
        let trimmedToken = token
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: "/")
            .last?
            .uppercased() ?? ""
        
        guard let registry = collabManager.registry(for: trimmedToken, in: registryRepo) else {
            errorMessage = "Invalid invite code or link. Please check and try again."
            showError = true
            return
        }
        
        // Check if this registry belongs to the current user
        let currentUserRegistries = registryRepo.registries
        if currentUserRegistries.contains(where: { $0.id == registry.id }) {
            errorMessage = "You can't join your own registry."
            showError = true
            return
        }
        
        showError = false
        joinedRegistryName = registry.displayName
        collabManager.addCollaborator(
            name: mockUserManager.currentUser.name,
            permission: .limited,
            to: registry.id,
            registryRepo: registryRepo
        )
        showSuccess = true
    }
}
