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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(subtitle)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(products) { product in
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
