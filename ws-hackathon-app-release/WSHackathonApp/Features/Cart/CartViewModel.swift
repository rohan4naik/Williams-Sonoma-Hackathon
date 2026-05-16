//
//  CartViewModel.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 05/04/26.
//

import Foundation
import Combine

@MainActor
final class CartViewModel: ObservableObject {

    @Published private(set) var items: [CartItem] = []
    @Published private(set) var savedItems: [CartItem] = []
    @Published private(set) var recommendations: [ProductItem] = []
    @Published private(set) var recentlyViewed: [ProductItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var repository: CartRepository?
    
    func bind(repository: CartRepository) {
        self.repository = repository
        self.items = repository.items
        self.savedItems = repository.savedItems
        
        repository.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedItems in
                self?.items = updatedItems
                self?.updateRecommendations()
                self?.updateSections()
            }
            .store(in: &cancellables)
            
        repository.$savedItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedSaved in
                self?.savedItems = updatedSaved
            }
            .store(in: &cancellables)
            
        ProductRepository.shared.$products
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateRecommendations()
                self?.updateSections()
            }
            .store(in: &cancellables)
    }
    
    var isEmptyCart: Bool {
        items.isEmpty
    }
    
    var totalPriceText: String {
        String(format: "$%.2f", repository?.totalPrice ?? 0)
    }
    
    func removeItem(_ item: CartItem) {
        repository?.remove(productId: item.id)
    }
    
    func add(_ item: CartItem) {
        repository?.increaseQuantity(productId: item.id)
    }
    
    func deleteItem(_ item: CartItem) {
        repository?.delete(productId: item.id)
    }
    
    func saveForLater(_ item: CartItem) {
        repository?.saveForLater(productId: item.id)
    }
    
    func moveToCart(_ item: CartItem) {
        repository?.moveToCart(productId: item.id)
    }
    
    func removeFromSaved(_ item: CartItem) {
        repository?.removeFromSaved(productId: item.id)
    }
    
    func addToCart(product: ProductItem) {
        repository?.add(product: product)
    }
    
    private func updateRecommendations() {
        self.recommendations = SmartRecommendationService.shared.getRecommendations(
            for: items,
            from: ProductRepository.shared.products
        )
    }
    
    private func updateSections() {
        let allProducts = ProductRepository.shared.products
        let cartIds = Set(items.map { $0.id })
        
        // Simulate recently viewed
        self.recentlyViewed = Array(allProducts.filter { !cartIds.contains($0.id) }.suffix(6).reversed())
        
    }
}
