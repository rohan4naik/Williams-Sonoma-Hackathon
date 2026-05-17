//
//  CategoryDetailView.swift
//  WSHackathonApp
//

import SwiftUI

struct CategoryDetailView: View {
    let categoryName: String
    let allProducts: [ProductItem]

    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    @State private var searchText = ""
    @State private var showFilterSheet = false
    @State private var selectedSort: SortOption = .newest
    @State private var maxPrice: Double = 1000
    
    @State private var filteredProducts: [ProductItem] = []
    
    private var searchResults: [ProductItem] {
        var results = filteredProducts
        
        if !searchText.isEmpty {
            results = results.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        results = results.filter { ($0.price ?? 0.0) <= maxPrice }
        
        switch selectedSort {
        case .newest:
            break // Default order
        case .priceHighToLow:
            results.sort { ($0.price ?? 0.0) > ($1.price ?? 0.0) }
        case .priceLowToHigh:
            results.sort { ($0.price ?? 0.0) < ($1.price ?? 0.0) }
        }
        
        return results
    }

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Count banner
                HStack {
                    Text("\(filteredProducts.count) items")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 16)

                // MARK: - Product Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(searchResults) { product in
                        NavigationLink(destination: ProductDetailView(
                            product: product,
                            relatedProducts: Array(filteredProducts.filter { $0.id != product.id }.shuffled().prefix(6))
                        )) {
                            ProductCardView(
                                product: product,
                                quantity: quantity(for: product),
                                registryQuantity: registryQuantity(for: product),
                                onAdd: { addToCart(product) },
                                onRemove: { removeFromCart(product) },
                                onAddToRegistry: {
                                    if canAddToRegistry(product) {
                                        addToRegistry(product)
                                    } else {
                                        tabBarVM.selectTab(.registry)
                                    }
                                },
                                onRemoveFromRegistry: { removeFromRegistry(product) }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 32)
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search products")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showFilterSheet = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            CategoryFilterSheet(selectedSort: $selectedSort, priceRange: $maxPrice)
                .presentationDetents([.medium, .large])
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if filteredProducts.isEmpty {
                let matched = allProducts.filter { product in
                    guard let type = product.productType else { return false }
                    return type.localizedCaseInsensitiveContains(categoryName) ||
                           categoryName.localizedCaseInsensitiveContains(type)
                }
                filteredProducts = matched.isEmpty ? Array(allProducts.shuffled().prefix(12)) : matched
            }
        }
    }

    // MARK: - Cart Helpers
    private func addToCart(_ product: ProductItem) {
        cartRepository.add(product: product)
    }

    private func removeFromCart(_ product: ProductItem) {
        cartRepository.remove(productId: product.id)
    }

    private func quantity(for product: ProductItem) -> Int {
        cartRepository.items.first(where: { $0.id == product.id })?.quantity ?? 0
    }

    // MARK: - Registry Helpers
    private func addToRegistry(_ product: ProductItem) {
        guard let activeId = registryRepository.activeRegistryId else { return }
        let registryItem = RegistryItem(
            id: product.id,
            title: product.title,
            price: product.price ?? 0.0,
            imageUrl: product.path,
            quantity: 1
        )
        registryRepository.addProduct(registryItem, to: activeId)
    }

    private func canAddToRegistry(_ product: ProductItem) -> Bool {
        return registryRepository.activeRegistryId != nil
    }

    private func removeFromRegistry(_ product: ProductItem) {
        guard let activeId = registryRepository.activeRegistryId else { return }
        registryRepository.removeProduct(productId: product.id, from: activeId)
    }

    private func registryQuantity(for product: ProductItem) -> Int {
        guard let activeId = registryRepository.activeRegistryId else { return 0 }
        return registryRepository.registries
            .first(where: { $0.id == activeId })?
            .items.first(where: { $0.id == product.id })?
            .quantity ?? 0
    }
}
