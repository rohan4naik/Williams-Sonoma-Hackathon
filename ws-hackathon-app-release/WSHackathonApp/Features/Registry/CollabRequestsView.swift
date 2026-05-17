//
//  CollabRequestsView.swift
//  WSHackathonApp
//

import SwiftUI

struct CollabRequestsView: View {
    let registryId: UUID
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var collabManager: CollaborationManager
    
    var pendingRequests: [CollabRequest] {
        collabManager.pendingRequests(for: registryId)
    }
    
    var body: some View {
        List {
            if pendingRequests.isEmpty {
                ProfileEmptyStateView(
                    title: "No Pending Requests",
                    systemImage: "checkmark.circle",
                    description: "All collaborator requests have been handled."
                )
            } else {
                ForEach(pendingRequests) { request in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(request.collaboratorName)
                                    .font(.headline)
                                Text(request.createdAt.formatted(
                                    date: .abbreviated, time: .shortened
                                ))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(request.status.rawValue)
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        
                        // Action description
                        HStack(spacing: 8) {
                            switch request.action {
                            case .add(let item):
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text("Wants to add: \(item.title)")
                                    .font(.subheadline)
                            case .remove(_, let title):
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                Text("Wants to remove: \(title)")
                                    .font(.subheadline)
                            }
                        }
                        
                        // Approve / Reject
                        HStack(spacing: 12) {
                            Button(action: {
                                collabManager.approveRequest(
                                    id: request.id,
                                    registryRepo: registryRepo
                                )
                            }) {
                                Text("Approve")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                collabManager.rejectRequest(id: request.id)
                            }) {
                                Text("Reject")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.red.opacity(0.1))
                                    .foregroundColor(.red)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Pending Requests")
        .navigationBarTitleDisplayMode(.inline)
    }
}
