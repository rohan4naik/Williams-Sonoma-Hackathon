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
        
        var item = items[index]
        item.isSaved = true
        
        // Add to savedItems if not already there
        if !savedItems.contains(where: { $0.id == item.id }) {
            savedItems.append(item)
        }
        
        // Remove from active cart
        items.remove(at: index)
        
        saveCart()
    }
    
    func saveForLater(product: ProductItem) {
        if !savedItems.contains(where: { $0.id == product.id }) {
            let newItem = CartItem(
                id: product.id,
                title: product.title,
                price: product.price ?? 0.0,
                path: product.path,
                brand: product.brand,
                collection: product.collection,
                availability: product.availability,
                canGiftWrap: product.canGiftWrap,
                quantity: 1,
                isSaved: true
            )
            savedItems.append(newItem)
            saveCart()
        }
    }
    
    func isSaved(productId: String) -> Bool {
        savedItems.contains(where: { $0.id == productId })
    }
    
    func moveToCart(productId: String) {
        guard let index = savedItems.firstIndex(where: { $0.id == productId }) else { return }
        var item = savedItems.remove(at: index)
        item.isSaved = false
        if let cartIndex = items.firstIndex(where: { $0.id == item.id }) {
            items[cartIndex].quantity += 1
            items[cartIndex].isSaved = false
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
        
        // Seed high-fidelity sample items with smart badges to wow the user
        if savedItems.isEmpty || !savedItems.contains(where: { $0.id == "2453926" }) {
            savedItems = [
                CartItem(
                    id: "2453926",
                    title: "Staub Enameled Cast Iron Round Dutch Oven, 7-Qt., Basil",
                    price: 299.95,
                    path: "/img83m.jpg",
                    brand: "Staub",
                    collection: "Staub Cast Iron",
                    availability: "ON_HAND",
                    canGiftWrap: true,
                    quantity: 1,
                    isSaved: true,
                    priceDropText: "Save 36%",
                    lowStockText: nil,
                    isPopular: false
                ),
                CartItem(
                    id: "2505456",
                    title: "Williams Sonoma End-Grain Cutting Board, Acacia, 15\" X 20\"",
                    price: 129.95,
                    path: "/img17m.jpg",
                    brand: "Williams Sonoma",
                    collection: "Acacia Essentials",
                    availability: "LOW_STOCK",
                    canGiftWrap: true,
                    quantity: 1,
                    isSaved: true,
                    priceDropText: nil,
                    lowStockText: "Only 2 left!",
                    isPopular: false
                ),
                CartItem(
                    id: "8381456",
                    title: "Cuisinart PerfecTemp Programmable Coffee Maker with Glass Carafe, 14-cup",
                    price: 119.95,
                    path: "/img122m.jpg",
                    brand: "Cuisinart",
                    collection: "Cuisinart Coffee",
                    availability: "ON_HAND",
                    canGiftWrap: true,
                    quantity: 1,
                    isSaved: true,
                    priceDropText: nil,
                    lowStockText: nil,
                    isPopular: true
                )
            ]
            saveCart()
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
