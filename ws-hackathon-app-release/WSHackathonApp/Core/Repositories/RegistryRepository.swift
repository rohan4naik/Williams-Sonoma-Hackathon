//
//  RegistryRepository.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Combine
import Foundation

@MainActor
final class RegistryRepository: ObservableObject {
    
    @Published var registries: [Registry] = []
    @Published var activeRegistryId: UUID?
    
    // MARK: - Computed
    var isActiveRegistry: Bool {
        activeRegistryId != nil
    }
    
    var activeRegistry: Registry? {
        registries.first { $0.id == activeRegistryId }
    }
    
    // MARK: - Actions
    func createRegistry(firstName: String,
                        lastName: String,
                        event: RegistryEvent,
                        customTitle: String?,
                        date: Date,
                        imageData: Data?) {
        
        let newRegistry = Registry(
            id: UUID(),
            createdAt: Date(),
            firstName: firstName,
            lastName: lastName,
            event: event,
            customTitle: customTitle,
            date: date,
            imageData: imageData,
            items: []
        )
        
        registries.append(newRegistry)
        activeRegistryId = newRegistry.id
    }
    
    func deleteRegistry(id: UUID) {
        registries.removeAll { $0.id == id }
        if activeRegistryId == id {
            activeRegistryId = nil
        }
    }
    
    func setActiveRegistry(id: UUID?) {
        activeRegistryId = id
    }
    
    // MARK: - Product Management
    func addProduct(_ product: RegistryItem, to registryId: UUID) {
        guard let index = registries.firstIndex(where: { $0.id == registryId }) else { return }
        
        if let itemIndex = registries[index].items.firstIndex(where: { $0.id == product.id }) {
            registries[index].items[itemIndex].quantity += 1
        } else {
            registries[index].items.append(product)
        }
    }
    
    func removeProduct(productId: String, from registryId: UUID) {
        guard let index = registries.firstIndex(where: { $0.id == registryId }) else { return }
        registries[index].items.removeAll { $0.id == productId }
    }
    
    // MARK: - Quantity Helpers
    func increaseQty(_ productId: String, for registryId: UUID) {
        guard let index = registries.firstIndex(where: { $0.id == registryId }) else { return }
        if let itemIndex = registries[index].items.firstIndex(where: { $0.id == productId }) {
            registries[index].items[itemIndex].quantity += 1
        }
    }
    
    func decreaseQty(_ productId: String, for registryId: UUID) {
        guard let index = registries.firstIndex(where: { $0.id == registryId }) else { return }
        guard let itemIndex = registries[index].items.firstIndex(where: { $0.id == productId }) else { return }
        
        if registries[index].items[itemIndex].quantity > 1 {
            registries[index].items[itemIndex].quantity -= 1
        } else {
            registries[index].items.remove(at: itemIndex)
        }
    }
    
    func quantity(for registryItem: RegistryItem, in registryId: UUID) -> Int {
        registries.first { $0.id == registryId }?.items.first(where: { $0.id == registryItem.id })?.quantity ?? 0
    }
}
