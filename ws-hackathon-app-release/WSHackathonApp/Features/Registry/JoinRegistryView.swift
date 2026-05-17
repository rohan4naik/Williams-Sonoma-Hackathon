//
//  JoinRegistryView.swift
//  WSHackathonApp
//

import SwiftUI

struct JoinRegistryView: View {
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var collabManager: CollaborationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var token = ""
    @State private var yourName = ""
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
                    
                    // Your name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("e.g. Jane Smith", text: $yourName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
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
        !token.trimmingCharacters(in: .whitespaces).isEmpty &&
        !yourName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func joinRegistry() {
        var trimmedToken = token.trimmingCharacters(in: .whitespaces).uppercased()
        
        // Extract token from full link "ws://registry/CODE" or "WS://REGISTRY/CODE"
        if trimmedToken.hasPrefix("WS://REGISTRY/") {
            trimmedToken = trimmedToken.replacingOccurrences(of: "WS://REGISTRY/", with: "")
        } else if let url = URL(string: token.trimmingCharacters(in: .whitespaces)),
                  url.scheme?.lowercased() == "ws" && url.host?.lowercased() == "registry" {
            trimmedToken = url.lastPathComponent.uppercased()
        } else if trimmedToken.contains("/") {
            trimmedToken = trimmedToken.components(separatedBy: "/").last ?? trimmedToken
        }
        
        guard let registry = collabManager.registry(
            for: trimmedToken,
            in: registryRepo.registries
        ) else {
            errorMessage = "Invalid invite code or link. Please check and try again."
            showError = true
            return
        }
        
        showError = false
        joinedRegistryName = registry.displayName
        collabManager.addCollaborator(
            name: yourName,
            permission: .limited,
            to: registry.id
        )
        showSuccess = true
    }
}
