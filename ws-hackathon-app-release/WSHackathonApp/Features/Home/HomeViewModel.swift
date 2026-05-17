//
//  HomeViewModel.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 04/04/26.
//
import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var products: [ProductItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var hasLoaded = false
    private var cartRepository: CartRepository?
    private var registryRepository: RegistryRepository?

    func bind(cartRepository: CartRepository,
              registryRepository: RegistryRepository) {
        self.cartRepository = cartRepository
        self.registryRepository = registryRepository
    }
    
    // MARK: - Cart

    func addToCart(_ product: ProductItem) {
        cartRepository?.add(product: product)
    }
    
    func removeFromCart(_ product: ProductItem) {
        cartRepository?.remove(productId: product.id)
    }
    
    // MARK: - Registry

    func addToRegistry(_ product: ProductItem) {
        guard let repo = registryRepository,
              let activeId = repo.activeRegistryId else { return }
        
        // Match pattern to a predefined registry category
        let matchedCategory = RegistryCategory.matchingCategory(
            for: product.pattern
        )
        // Find the actual category instance in the registry
        // (predefined categories are stored per-registry)
        let registry = repo.registries.first { $0.id == activeId }
        let categoryId = registry?.categories.first { 
            $0.name == matchedCategory?.name 
        }?.id
        
        let registryItem = RegistryItem(
            id: product.id,
            title: product.title,
            price: product.price ?? 0.0,
            imageUrl: product.path,
            quantity: 1,
            categoryId: categoryId
        )
        repo.addProduct(registryItem, to: activeId)
    }
    
    func canAddToRegistry(_ product: ProductItem) -> Bool {
        guard let repo = registryRepository else { return false }
        return repo.activeRegistryId != nil
    }
    
    func removeFromRegistry(_ product: ProductItem) {
        guard let repo = registryRepository,
              let activeId = repo.activeRegistryId else { return }
        repo.removeProduct(productId: product.id, from: activeId)
    }
    
    func quantity(for product: ProductItem) -> Int {
        cartRepository?.items.first(where: { $0.id == product.id })?.quantity ?? 0
    }
    
    func registryQuantity(for product: ProductItem) -> Int {
        guard let repo = registryRepository,
              let activeId = repo.activeRegistryId else { return 0 }
        return repo.registries
            .first(where: { $0.id == activeId })?
            .items.first(where: { $0.id == product.id })?
            .quantity ?? 0
    }
    
    // MARK: - Products

    var filteredProducts: [ProductItem] {
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func fetchProducts() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        
        isLoading = true
        errorMessage = nil
        
        do {
            let dtos: [ProductItemDTO] = try await APIClient.shared.request(Endpoint.products())
            let fetchedProducts = dtos.map { ProductItem(from: $0) }
            self.products = fetchedProducts
            await ProductRepository.shared.setProducts(fetchedProducts)
        } catch {
            print(error)
            errorMessage = "Failed to load products"
        }
        
        isLoading = false
    }
}
