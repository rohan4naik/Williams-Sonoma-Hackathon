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
    
    @Published var currentUserId: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    @Published var allUserRegistries: [UUID: [Registry]] = [:]
    
    // MARK: - Computed
    var isActiveRegistry: Bool {
        activeRegistryId != nil
    }
    
    var activeRegistry: Registry? {
        registries.first { $0.id == activeRegistryId }
    }
    
    // MARK: - Actions
    func switchUser(to userId: UUID) {
        // Save current user's registries
        allUserRegistries[currentUserId] = registries
        
        // Switch to the new user ID
        currentUserId = userId
        
        // Restore the new user's registries, or start fresh with empty array
        registries = allUserRegistries[userId] ?? []
        
        // Reset active registry selection
        activeRegistryId = registries.first?.id
    }
    
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
    
    private func locateAndModifyRegistry(id: UUID, block: (inout Registry) -> Void) {
        NSLog("DEBUG: locateAndModifyRegistry - searching for %@", id.uuidString)
        if let idx = registries.firstIndex(where: { $0.id == id }) {
            NSLog("DEBUG: locateAndModifyRegistry - found registry in current active registries at index %d", idx)
            block(&registries[idx])
        } else {
            var found = false
            for (userId, userRegs) in allUserRegistries {
                if let idx = userRegs.firstIndex(where: { $0.id == id }) {
                    NSLog("DEBUG: locateAndModifyRegistry - found registry in allUserRegistries for user %@ at index %d", userId.uuidString, idx)
                    var modifiedRegs = userRegs
                    block(&modifiedRegs[idx])
                    allUserRegistries[userId] = modifiedRegs
                    found = true
                    break
                }
            }
            if !found {
                NSLog("DEBUG: locateAndModifyRegistry - registry NOT found anywhere!")
            }
        }
    }
    
    // MARK: - Product Management
    func addProduct(_ product: RegistryItem, to registryId: UUID) {
        NSLog("DEBUG: addProduct - product: %@, registryId: %@", product.title, registryId.uuidString)
        locateAndModifyRegistry(id: registryId) { registry in
            if let itemIndex = registry.items.firstIndex(where: { $0.id == product.id }) {
                registry.items[itemIndex].quantity += 1
                NSLog("DEBUG: addProduct - incremented qty to %d for existing product", registry.items[itemIndex].quantity)
            } else {
                registry.items.append(product)
                NSLog("DEBUG: addProduct - appended new product. Total items now: %d", registry.items.count)
            }
        }
    }
    
    func removeProduct(productId: String, from registryId: UUID) {
        NSLog("DEBUG: removeProduct - productId: %@, registryId: %@", productId, registryId.uuidString)
        locateAndModifyRegistry(id: registryId) { registry in
            let initialCount = registry.items.count
            registry.items.removeAll { $0.id == productId }
            NSLog("DEBUG: removeProduct - removed. Initial count: %d, final count: %d", initialCount, registry.items.count)
        }
    }
    
    // MARK: - Quantity Helpers
    func increaseQty(_ productId: String, for registryId: UUID) {
        locateAndModifyRegistry(id: registryId) { registry in
            if let itemIndex = registry.items.firstIndex(where: { $0.id == productId }) {
                registry.items[itemIndex].quantity += 1
            }
        }
    }
    
    func decreaseQty(_ productId: String, for registryId: UUID) {
        locateAndModifyRegistry(id: registryId) { registry in
            guard let itemIndex = registry.items.firstIndex(where: { $0.id == productId }) else { return }
            if registry.items[itemIndex].quantity > 1 {
                registry.items[itemIndex].quantity -= 1
            } else {
                registry.items.remove(at: itemIndex)
            }
        }
    }
    
    func quantity(for registryItem: RegistryItem, in registryId: UUID) -> Int {
        let allRegistries = allUserRegistries.values.flatMap { $0 } + registries
        return allRegistries.first { $0.id == registryId }?.items.first(where: { $0.id == registryItem.id })?.quantity ?? 0
    }
    
    func purchasedQuantity(for registryItem: RegistryItem, in registryId: UUID) -> Int {
        let allRegistries = allUserRegistries.values.flatMap { $0 } + registries
        return allRegistries.first { $0.id == registryId }?.items.first(where: { $0.id == registryItem.id })?.purchasedQuantity ?? 0
    }
    
    // MARK: - Categorization
    
    // Toggle categorization mode on/off for a registry
    func toggleCategorized(for registryId: UUID) {
        locateAndModifyRegistry(id: registryId) { registry in
            registry.isCategorized.toggle()
        }
    }
    
    // Add a custom category to a specific registry
    func addCustomCategory(name: String, to registryId: UUID) -> RegistryCategory? {
        let newCategory = RegistryCategory(id: UUID(), name: name, isCustom: true)
        var success = false
        locateAndModifyRegistry(id: registryId) { registry in
            registry.categories.append(newCategory)
            success = true
        }
        return success ? newCategory : nil
    }
    
    // Delete a custom category — reassign its items to nil (uncategorized)
    func deleteCustomCategory(categoryId: UUID, from registryId: UUID) {
        locateAndModifyRegistry(id: registryId) { registry in
            // Remove the category
            registry.categories.removeAll { $0.id == categoryId }
            
            // Reassign items to nil (uncategorized)
            for itemIndex in registry.items.indices {
                if registry.items[itemIndex].categoryId == categoryId {
                    registry.items[itemIndex].categoryId = nil
                    registry.items[itemIndex].customCategoryName = nil
                }
            }
        }
    }
    
    // Move an item to a different category (for drag and drop)
    func moveItem(itemId: String, toCategoryId: UUID?, in registryId: UUID) {
        locateAndModifyRegistry(id: registryId) { registry in
            guard let itemIndex = registry.items.firstIndex(where: { $0.id == itemId }) else { return }
            
            registry.items[itemIndex].categoryId = toCategoryId
            
            if let catId = toCategoryId,
               let category = registry.categories.first(where: { $0.id == catId }) {
                if category.isCustom {
                    registry.items[itemIndex].customCategoryName = category.name
                } else {
                    registry.items[itemIndex].customCategoryName = nil
                }
            } else {
                registry.items[itemIndex].customCategoryName = nil
            }
        }
    }
}
