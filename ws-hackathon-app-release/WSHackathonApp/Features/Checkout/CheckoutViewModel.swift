//
//  CheckoutViewModel.swift
//  WSHackathonApp
//
//  Created by Antigravity on 16/05/26.
//

import SwiftUI
import Combine

@MainActor
class CheckoutViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var firstName: String = "John"
    @Published var lastName: String = "Doe"
    @Published var streetAddress: String = "123 Williams Sonoma Way"
    @Published var city: String = "San Francisco"
    @Published var state: String = "CA"
    @Published var zipCode: String = "94109"
    @Published var phoneNumber: String = "(415) 555-0123"
    
    @Published var showingAddressEditor: Bool = false
    @Published var showingDeliveryDropdown: Bool = false
    @Published var selectedDeliveryMethod: DeliveryMethod = .standard
    @Published var paymentMethod: PaymentMethodType = .applePay
    @Published var promoCode: String = ""
    @Published var discountAmount: Double = 0
    @Published var isPromoApplied: Bool = false
    @Published var isProcessing: Bool = false
    @Published var orderPlaced: Bool = false
    
    var fullAddress: String {
        "\(firstName) \(lastName)\n\(streetAddress)\n\(city), \(state) \(zipCode)\n\(phoneNumber)"
    }
    
    func applyPromoCode() {
        // Simulation: SAVE10 gives 10% discount, SAVE20 gives 20%
        if promoCode.uppercased() == "SAVE10" {
            discountAmount = subtotal * 0.10
            isPromoApplied = true
        } else if promoCode.uppercased() == "SAVE20" {
            discountAmount = subtotal * 0.20
            isPromoApplied = true
        } else {
            discountAmount = 0
            isPromoApplied = false
        }
    }
    
    private var cartRepository: CartRepository?
    private var cancellables = Set<AnyCancellable>()
    
    enum DeliveryMethod: String, CaseIterable {
        case standard = "Standard (3-5 days)"
        case express = "Express (1-2 days)"
        case overnight = "Overnight (Next day)"
        
        var price: Double {
            switch self {
            case .standard: return 15.0
            case .express: return 25.0
            case .overnight: return 45.0
            }
        }
    }
    
    enum PaymentMethodType {
        case applePay
        case paypal
    }
    
    func bind(repository: CartRepository) {
        self.cartRepository = repository
        self.items = repository.items
        
        repository.$items
            .sink { [weak self] items in
                self?.items = items
            }
            .store(in: &cancellables)
    }
    
    var subtotal: Double {
        items.reduce(0) { total, cartItem in
            let itemContributions = CollaborationManager.shared.contributions
                .filter { $0.itemId == cartItem.id }
            let totalContributedForThisItem = itemContributions.reduce(0.0) { $0 + $1.amount }
            let itemTotal = (cartItem.price * Double(cartItem.quantity)) - totalContributedForThisItem
            return total + max(0.0, itemTotal)
        }
    }
    
    var shippingFee: Double {
        if subtotal >= 150 && selectedDeliveryMethod == .standard {
            return 0
        }
        return selectedDeliveryMethod.price
    }
    
    var tax: Double {
        max(subtotal - discountAmount, 0) * 0.085 // 8.5% tax simulation
    }
    
    var total: Double {
        max(subtotal - discountAmount, 0) + shippingFee + tax
    }
    
    func placeOrder() {
        isProcessing = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isProcessing = false
            self.orderPlaced = true
            
            self.cartRepository?.clearCart()
        }
    }
}
