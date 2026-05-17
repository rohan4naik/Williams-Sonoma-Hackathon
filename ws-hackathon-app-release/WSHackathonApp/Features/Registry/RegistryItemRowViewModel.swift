//
//  RegistryItemRowViewModel.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class RegistryItemRowViewModel: ObservableObject {
    
    let item: RegistryItem
    let registryId: UUID
    
    private let registryRepo: RegistryRepository
    private let cartRepo: CartRepository
    private let tabBarVM: WSTabBarViewModel

    init(item: RegistryItem,
         registryId: UUID,
         registryRepo: RegistryRepository,
         cartRepo: CartRepository,
         tabbarVM: WSTabBarViewModel) {
        self.item = item
        self.registryId = registryId
        self.registryRepo = registryRepo
        self.cartRepo = cartRepo
        self.tabBarVM = tabbarVM
    }
    
    // MARK: - Display
    
    var title: String { item.title }
    
    var priceText: String {
        "$\(item.price, default: "%.2f")"
    }
    
    var quantityText: String {
        "\(registryRepo.quantity(for: item, in: registryId))"
    }
    
    var imageURL: URL? {
        guard let url = item.imageUrl else { return nil }
        if url.contains("example.com") || url.contains("placeholder") || url.isEmpty {
            let cleanQuery = item.title
                .lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty && $0.count > 2 }
                .joined(separator: ",")
            return URL(string: "https://loremflickr.com/600/600/\(cleanQuery.isEmpty ? "kitchen" : cleanQuery)")
        }
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            return URL(string: url)
        }
        return URL(string: AppConstants.API.imageBasePath + url)
    }
    
    var requestedQuantity: Int {
        registryRepo.quantity(for: item, in: registryId)
    }
    
    var purchasedQuantity: Int {
        registryRepo.purchasedQuantity(for: item, in: registryId)
    }
    
    var isFullyFunded: Bool {
        let requested = requestedQuantity
        let purchased = purchasedQuantity
        return purchased >= requested && requested > 0
    }
    
    var purchasedProgress: Double {
        let requested = requestedQuantity
        guard requested > 0 else { return 0.0 }
        return min(Double(purchasedQuantity) / Double(requested), 1.0)
    }
    
    // MARK: - Actions
    
    func increaseQty() {
        registryRepo.increaseQty(item.id, for: registryId)
    }
    
    func decreaseQty() {
        registryRepo.decreaseQty(item.id, for: registryId)
    }
    
    func removeItem() {
        registryRepo.removeProduct(productId: item.id, from: registryId)
    }
    
    func addToCart() {
        let product = ProductItem(
            id: item.id,
            title: item.title,
            price: item.price,
            path: item.imageUrl
        )
        let quantityInRegistry = registryRepo.quantity(for: item, in: registryId)
        
        cartRepo.add(product: product, quantity: quantityInRegistry)
    }
}
