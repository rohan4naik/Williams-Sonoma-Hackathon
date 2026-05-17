//
//  CollabRequestsView.swift
//  WSHackathonApp
//

import SwiftUI

struct CollabRequestsView: View {
    let registryId: UUID
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var collabManager: CollaborationManager
    @EnvironmentObject var mockUserManager: MockUserManager
    
    private var isOwner: Bool {
        let currentUserId = mockUserManager.currentUser.id
        let currentUserRegistries = registryRepo.allUserRegistries[currentUserId]
            ?? registryRepo.registries
        return currentUserRegistries.contains { $0.id == registryId }
    }
    
    var pendingRequests: [CollabRequest] {
        collabManager.pendingRequests(for: registryId)
    }
    
    var registryContributions: [Contribution] {
        collabManager.contributions.filter { $0.registryId == registryId }
            .sorted(by: { $0.date > $1.date }) // latest first
    }
    
    var body: some View {
        VStack {
            if !isOwner {
                // Access denied UI
                VStack(spacing: 20) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Owner Access Only")
                        .font(.title3.bold())
                    Text("Only the registry owner can review and approve requests.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 60)
            } else {
                List {
                    if pendingRequests.isEmpty && registryContributions.isEmpty {
                        ProfileEmptyStateView(
                            title: "No Updates Yet",
                            systemImage: "bell.slash",
                            description: "No collaborator requests or contributions have occurred yet."
                        )
                    } else {
                        // Section 1: Actionable Requests (Awaiting Approval)
                        if !pendingRequests.isEmpty {
                            Section(header: Text("Awaiting Approval").font(.headline).foregroundColor(.primary)) {
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
                                            .buttonStyle(BorderlessButtonStyle())
                                            
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
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        
                        // Section 2: Informational Contributions (Gifts & Contributions Activity Log)
                        if !registryContributions.isEmpty {
                            Section(header: Text("Gifts & Contributions").font(.headline).foregroundColor(.primary)) {
                                ForEach(registryContributions) { contribution in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(contribution.isFullPayment ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: contribution.isFullPayment ? "gift.fill" : "dollarsign.circle.fill")
                                                    .foregroundColor(contribution.isFullPayment ? .green : .blue)
                                                    .font(.system(size: 16))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(contribution.contributorName)
                                                    .font(.system(size: 15, weight: .semibold))
                                                Text(contribution.date.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            
                                            Text(contribution.amount.formatted(.currency(code: "USD")))
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(contribution.isFullPayment ? .green : .primary)
                                        }
                                        
                                        Text(contribution.isFullPayment ?
                                             "Gifted \"\(contribution.itemTitle)\" in full!" :
                                             "Contributed to \"\(contribution.itemTitle)\"")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 52)
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Pending Requests")
        .navigationBarTitleDisplayMode(.inline)
    }
}
