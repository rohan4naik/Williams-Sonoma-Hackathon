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
    @State private var searchText = ""
    
    private var registry: Registry? {
        registryRepo.registries.first { $0.id == registryId }
    }
    
    var searchResults: [ProductItem] {
        if searchText.isEmpty {
            return []
        } else {
            return ProductRepository.shared.products.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var suggestedProducts: [ProductItem] {
        guard let registry = registry else { return [] }
        let allProducts = ProductRepository.shared.products
        
        let keywords: [String]
        switch registry.event {
        case .birthday:
            keywords = ["gift", "cake", "party", "sweet", "baking"]
        case .wedding:
            keywords = ["set", "cookware", "electrics", "tabletop", "glass"]
        case .housewarming:
            keywords = ["home", "decor", "essentials", "towels", "pan"]
        case .anniversary:
            keywords = ["wine", "glass", "premium", "gift", "plate"]
        case .other:
            keywords = ["popular", "best", "new", "exclusive"]
        }
        
        let filtered = allProducts.filter { product in
            let titleLower = product.title.lowercased()
            let typeLower = product.productType?.lowercased() ?? ""
            return keywords.contains { titleLower.contains($0) || typeLower.contains($0) }
        }
        
        if filtered.count >= 5 {
            return Array(filtered.shuffled().prefix(6))
        } else {
            return Array(allProducts.shuffled().prefix(6))
        }
    }
    
    var body: some View {
        Group {
            if let registry = registry {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        if searchText.isEmpty {
                            // MARK: - Registry Details
                            
                            // Header Card
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
                            
                            // Items List
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
                            
                            // Actions
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
                            
                            // MARK: - AI Suggestions
                            aiSuggestionsSection
                            
                        } else {
                            // MARK: - Search Results
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Search Results")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                
                                if searchResults.isEmpty {
                                    ContentUnavailableView("No products found", systemImage: "magnifyingglass", description: Text("Try adjusting your search."))
                                } else {
                                    VStack(spacing: 12) {
                                        ForEach(searchResults) { product in
                                            RegistryProductSearchRow(product: product, registryId: registryId)
                                                .environmentObject(registryRepo)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
                .navigationTitle(registry.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, prompt: "Search products to add...")
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
    
    private var aiSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .font(.title3)
                Text("AI Suggestions")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 16)
            
            Text("Trending items people generally order for a \(registry?.event.title.lowercased() ?? "event").")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(suggestedProducts) { product in
                        RegistrySuggestionCard(product: product, registryId: registryId)
                            .environmentObject(registryRepo)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Search Row View
struct RegistryProductSearchRow: View {
    let product: ProductItem
    let registryId: UUID
    @EnvironmentObject var registryRepo: RegistryRepository
    
    var quantityInRegistry: Int {
        guard let registry = registryRepo.registries.first(where: { $0.id == registryId }),
              let item = registry.items.first(where: { $0.id == product.id }) else {
            return 0
        }
        return item.quantity
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image
            AsyncImage(url: product.imageURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                if let price = product.price {
                    Text(price.formatted(.currency(code: "USD")))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            // Quantity Controls
            HStack(spacing: 12) {
                Button {
                    registryRepo.decreaseQty(product.id, for: registryId)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(quantityInRegistry > 0 ? .black : .gray)
                        .frame(width: 28, height: 28)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .disabled(quantityInRegistry == 0)
                
                Text("\(quantityInRegistry)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(minWidth: 20)
                
                Button {
                    if quantityInRegistry == 0 {
                        // First time adding
                        let newItem = RegistryItem(
                            id: product.id,
                            title: product.title,
                            price: product.price ?? 0.0,
                            imageUrl: product.path,
                            quantity: 1
                        )
                        registryRepo.addProduct(newItem, to: registryId)
                    } else {
                        // Already added, just increment
                        registryRepo.increaseQty(product.id, for: registryId)
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.black)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - AI Suggestion Card View
struct RegistrySuggestionCard: View {
    let product: ProductItem
    let registryId: UUID
    @EnvironmentObject var registryRepo: RegistryRepository
    
    var isAdded: Bool {
        guard let registry = registryRepo.registries.first(where: { $0.id == registryId }) else { return false }
        return registry.items.contains(where: { $0.id == product.id })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product Image
            AsyncImage(url: product.imageURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(2)
                    .frame(height: 36, alignment: .topLeading)
                
                if let price = product.price {
                    Text(price.formatted(.currency(code: "USD")))
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .padding(.horizontal, 8)
            
            // Add Button
            Button {
                if !isAdded {
                    let newItem = RegistryItem(
                        id: product.id,
                        title: product.title,
                        price: product.price ?? 0.0,
                        imageUrl: product.path,
                        quantity: 1
                    )
                    registryRepo.addProduct(newItem, to: registryId)
                }
            } label: {
                Text(isAdded ? "Added" : "+ Add")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isAdded ? .gray : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isAdded ? Color(.systemGray5) : Color.black)
                    .cornerRadius(8)
            }
            .disabled(isAdded)
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .frame(width: 140)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}
