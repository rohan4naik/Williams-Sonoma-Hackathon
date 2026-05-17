import SwiftUI

struct HeroDetailView: View {
    let title: String
    let subtitle: String
    let products: [ProductItem]
    
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @State private var searchText = ""
    @State private var showFilterSheet = false
    @State private var selectedSort: SortOption = .newest
    @State private var maxPrice: Double = 1000
    
    private var searchResults: [ProductItem] {
        var results = products
        
        if !searchText.isEmpty {
            results = results.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        results = results.filter { ($0.price ?? 0.0) <= maxPrice }
        
        switch selectedSort {
        case .newest:
            break
        case .priceHighToLow:
            results.sort { ($0.price ?? 0.0) > ($1.price ?? 0.0) }
        case .priceLowToHigh:
            results.sort { ($0.price ?? 0.0) < ($1.price ?? 0.0) }
        }
        
        return results
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(subtitle)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                HStack {
                    Text("\(searchResults.count) items")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(searchResults) { product in
                        NavigationLink(destination: ProductDetailView(
                            product: product,
                            relatedProducts: Array(products.filter { $0.id != product.id }.shuffled().prefix(6))
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
            }
            .padding(.vertical)
        }
        .navigationTitle(title)
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
