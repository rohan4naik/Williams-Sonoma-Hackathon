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
    private var cancellables = Set<AnyCancellable>()

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
        
        // Subscribe to repository updates to automatically publish changes
        registryRepo.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
            
        collabManager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Display
    
    var title: String { item.title }
    
    var priceText: String {
        let remaining = max(0.0, item.price - totalContributed)
        return String(format: "$%.2f", remaining)
    }
    
    var totalContributed: Double {
        collabManager.contributions(for: item.id, in: registryId)
            .reduce(0.0) { $0 + $1.amount }
    }
    
    var quantityText: String {
        "\(registryRepo.quantity(for: item, in: registryId))"
    }
    
    var imageURL: URL? {
        ProductImageResolver.resolveImageURL(forTitle: item.title, path: item.imageUrl)
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
        let unitPaid = totalContributed >= item.price
        return (purchased >= requested && requested > 0) || unitPaid
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
        if totalContributed > 0 && requestedQuantity <= 1 {
            // Cannot remove/decrease the product to 0 if there are contributions
            return
        }
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
        guard totalContributed == 0 else { return }
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
