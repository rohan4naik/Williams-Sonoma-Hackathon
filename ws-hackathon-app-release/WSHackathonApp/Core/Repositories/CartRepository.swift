//
//  CartRepository.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
import Combine

@MainActor
final class CartRepository: ObservableObject {
    
    @Published private(set) var items: [CartItem] = []
    @Published private(set) var savedItems: [CartItem] = []
    
    private let cartKey = "ws_cart_items"
    private let savedKey = "ws_saved_items"
    
    init() {
        loadCart()
    }
    
    // MARK: - Add Item
    func add(product: ProductItem, quantity: Int = 1) {
        guard let priceValue = product.price else { return }
        
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            items[index].quantity += quantity
        } else {
            let newItem = CartItem(
                id: product.id,
                title: product.title,
                price: priceValue,
                path: product.path,
                brand: product.brand,
                collection: product.collection,
                availability: product.availability,
                canGiftWrap: product.canGiftWrap,
                quantity: quantity
            )
            items.append(newItem)
        }
        saveCart()
    }
    
    // MARK: - Remove Item
    func remove(productId: String) {
        guard let index = items.firstIndex(where: { $0.id == productId }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
        saveCart()
    }
    
    func delete(productId: String) {
        items.removeAll { $0.id == productId }
        saveCart()
    }
    
    // MARK: - Save for Later
    func saveForLater(productId: String) {
        guard let index = items.firstIndex(where: { $0.id == productId }) else { return }
        let item = items.remove(at: index)
        if !savedItems.contains(where: { $0.id == item.id }) {
            savedItems.append(item)
        }
        saveCart()
    }
    
    func moveToCart(productId: String) {
        guard let index = savedItems.firstIndex(where: { $0.id == productId }) else { return }
        let item = savedItems.remove(at: index)
        if let cartIndex = items.firstIndex(where: { $0.id == item.id }) {
            items[cartIndex].quantity += 1
        } else {
            items.append(item)
        }
        saveCart()
    }

    func removeFromSaved(productId: String) {
        savedItems.removeAll { $0.id == productId }
        saveCart()
    }
    
    // MARK: - Persistence
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: cartKey)
        }
        if let encoded = try? JSONEncoder().encode(savedItems) {
            UserDefaults.standard.set(encoded, forKey: savedKey)
        }
    }
    
    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: cartKey),
           let decoded = try? JSONDecoder().decode([CartItem].self, from: data) {
            items = decoded
        }
        if let data = UserDefaults.standard.data(forKey: savedKey),
           let decoded = try? JSONDecoder().decode([CartItem].self, from: data) {
            savedItems = decoded
        }
    }

    // MARK: - Total Calculations
    var totalPrice: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    func increaseQuantity(productId: String) {
        guard let index = items.firstIndex(where: { $0.id == productId }) else { return }
        items[index].quantity += 1
        saveCart()
    }
    
    func clearCart() {
        items.removeAll()
        saveCart()
    }
}
