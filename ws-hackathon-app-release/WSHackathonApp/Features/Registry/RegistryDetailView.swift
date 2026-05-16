//
//  RegistryDetailView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 16/05/26.
//

import SwiftUI

struct RegistryDetailView: View {
    
    let registryId: UUID
    
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false
    
    private var registry: Registry? {
        registryRepo.registries.first { $0.id == registryId }
    }
    
    var body: some View {
        Group {
            if let registry = registry {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Header Card
                        HStack(spacing: 16) {
                            // Circular Image
                            Group {
                                if let imageData = registry.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    ZStack {
                                        Color(.systemGray6)
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(registry.displayName)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text(registry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(registry.event.title)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(4)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        
                        // MARK: - Items List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Items")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            if registry.items.isEmpty {
                                emptyItemsView
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(registry.items) { item in
                                        RegistryItemRow(
                                            viewModel: RegistryItemRowViewModel(
                                                item: item,
                                                registryId: registryId,
                                                registryRepo: registryRepo,
                                                cartRepo: cartRepo,
                                                tabbarVM: tabBarVM
                                            )
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // MARK: - Actions
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Registry")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    }
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
                .navigationTitle(registry.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .confirmationDialog(
                    "Are you sure you want to delete this registry?",
                    isPresented: $showingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        registryRepo.deleteRegistry(id: registryId)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            } else {
                ContentUnavailableView("Registry not found", systemImage: "tray")
            }
        }
        .onChange(of: registryRepo.registries) { _ in
            if registryRepo.registries.first(where: { $0.id == registryId }) == nil {
                dismiss()
            }
        }
    }
    
    private var emptyItemsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "basket")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            Text("No items added yet")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
