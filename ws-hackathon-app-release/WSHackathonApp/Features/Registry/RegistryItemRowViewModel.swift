//
//  RegistryItemRowViewModel.swift
//  WSHackathonApp
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
    private let collabManager: CollaborationManager
    private let currentUserName: String

    init(item: RegistryItem,
         registryId: UUID,
         registryRepo: RegistryRepository,
         cartRepo: CartRepository,
         tabbarVM: WSTabBarViewModel,
         collabManager: CollaborationManager,
         currentUserName: String) {
        self.item = item
        self.registryId = registryId
        self.registryRepo = registryRepo
        self.cartRepo = cartRepo
        self.tabBarVM = tabbarVM
        self.collabManager = collabManager
        self.currentUserName = currentUserName
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
    
    var currentUserPermission: CollabPermission? {
        collabManager.collaborators(for: registryId)
            .first { $0.name == currentUserName }?.permission
    }
    
    var isCollaborator: Bool {
        currentUserPermission != nil
    }
    
    var canActDirectly: Bool {
        !isCollaborator || currentUserPermission == .full
    }
    
    private var isOwner: Bool {
        let ownerRegistries = registryRepo.allUserRegistries.values
            .first(where: { registries in 
                registries.contains { $0.id == registryId }
            })
        // Check if current user's registries contain this registry
        return registryRepo.registries.contains { $0.id == registryId }
    }
    
    // MARK: - Actions
    
    func increaseQty() {
        if isOwner {
            registryRepo.increaseQty(item.id, for: registryId)
        } else {
            let actualPermission = collabManager
                .collaborators(for: registryId)
                .first { $0.name == currentUserName }?
                .permission ?? .limited
            
            let newItem = RegistryItem(
                id: item.id,
                title: item.title,
                price: item.price,
                imageUrl: item.imageUrl,
                quantity: 1,
                categoryId: item.categoryId
            )
            collabManager.submitRequest(
                registryId: registryId,
                collaboratorName: currentUserName,
                action: .add(newItem),
                permission: actualPermission,
                registryRepo: registryRepo
            )
        }
    }
    
    func decreaseQty() {
        if isOwner {
            registryRepo.decreaseQty(item.id, for: registryId)
        } else {
            let actualPermission = collabManager
                .collaborators(for: registryId)
                .first { $0.name == currentUserName }?
                .permission ?? .limited
            
            collabManager.submitRequest(
                registryId: registryId,
                collaboratorName: currentUserName,
                action: .remove(itemId: item.id, itemTitle: item.title),
                permission: actualPermission,
                registryRepo: registryRepo
            )
        }
    }
    
    func removeItem() {
        if isOwner {
            registryRepo.removeProduct(productId: item.id, from: registryId)
        } else {
            let actualPermission = collabManager
                .collaborators(for: registryId)
                .first { $0.name == currentUserName }?
                .permission ?? .limited
            
            collabManager.submitRequest(
                registryId: registryId,
                collaboratorName: currentUserName,
                action: .remove(itemId: item.id, itemTitle: item.title),
                permission: actualPermission,
                registryRepo: registryRepo
            )
        }
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
