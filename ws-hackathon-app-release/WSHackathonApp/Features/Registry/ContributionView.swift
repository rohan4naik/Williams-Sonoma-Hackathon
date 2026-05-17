//
//  ContributionView.swift
//  WSHackathonApp
//

import SwiftUI

struct ContributionView: View {
    let item: RegistryItem
    let registryId: UUID
    let currentUserName: String
    @EnvironmentObject var collabManager: CollaborationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var contributionAmount = ""
    @State private var showSuccess = false
    
    var existingContributions: [Contribution] {
        collabManager.contributions(for: item.id, in: registryId)
    }
    
    var totalContributed: Double {
        existingContributions.reduce(0) { $0 + $1.amount }
    }
    
    var remainingAmount: Double {
        max(0, item.price - totalContributed)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Item info
                    HStack(spacing: 16) {
                        AsyncImage(url: item.imageURL) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                Color(.systemGray5)
                            }
                        }
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                                .lineLimit(2)
                            Text(item.price.formatted(.currency(code: "USD")))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Contribution progress
                    if !existingContributions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contributions so far")
                                .font(.headline)
                            
                            ForEach(existingContributions) { contribution in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(contribution.isFullPayment ? 
                                             "Gifted by \(contribution.contributorName)" :
                                             "Contributed by \(contribution.contributorName)")
                                            .font(.subheadline)
                                        Text(contribution.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(contribution.amount.formatted(.currency(code: "USD")))
                                        .font(.subheadline.bold())
                                        .foregroundColor(contribution.isFullPayment ? .green : .primary)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.04), radius: 5)
                            }
                            
                            // Progress bar
                            VStack(alignment: .leading, spacing: 4) {
                                ProgressView(value: min(totalContributed, item.price), total: item.price)
                                    .tint(.black)
                                HStack {
                                    Text("\(totalContributed.formatted(.currency(code: "USD"))) contributed")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(remainingAmount.formatted(.currency(code: "USD"))) remaining")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Gift fully button
                    Button(action: {
                        collabManager.addContribution(
                            registryId: registryId,
                            itemId: item.id,
                            itemTitle: item.title,
                            contributorName: currentUserName,
                            amount: item.price,
                            isFullPayment: true
                        )
                        showSuccess = true
                    }) {
                        HStack {
                            Image(systemName: "gift.fill")
                            Text("Gift Fully (\(item.price.formatted(.currency(code: "USD"))))")
                        }
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(remainingAmount == 0)
                    
                    // Partial contribution
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Or contribute a partial amount")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            HStack {
                                Text("$")
                                    .foregroundColor(.secondary)
                                TextField("Amount", text: $contributionAmount)
                                    .keyboardType(.decimalPad)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            Button(action: {
                                guard let amount = Double(contributionAmount),
                                      amount > 0 else { return }
                                collabManager.addContribution(
                                    registryId: registryId,
                                    itemId: item.id,
                                    itemTitle: item.title,
                                    contributorName: currentUserName,
                                    amount: min(amount, remainingAmount),
                                    isFullPayment: false
                                )
                                contributionAmount = ""
                                showSuccess = true
                            }) {
                                Text("Contribute")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(contributionAmount.isEmpty || remainingAmount == 0)
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle("Contribute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Thank you!", isPresented: $showSuccess) {
                Button("Done") { dismiss() }
            } message: {
                Text("Your contribution has been recorded.")
            }
        }
    }
}
