//
//  SmartRecommendationService.swift
//  WSHackathonApp
//

import Foundation

@MainActor
final class SmartRecommendationService {
    
    static let shared = SmartRecommendationService()
    private init() {}
    
    /// Get recommendations based on current cart items
    func getRecommendations(for cartItems: [CartItem], from allProducts: [ProductItem]) -> [ProductItem] {
        guard !cartItems.isEmpty else {
            // If cart is empty, suggest top products (e.g., first 5)
            return Array(allProducts.prefix(5))
        }
        
        let cartIds = Set(cartItems.map { $0.id })
        var recommendations: [ProductItem] = []
        
        for item in cartItems {
            // Find products in same collection or brand
            let matched = allProducts.filter { product in
                !cartIds.contains(product.id) &&
                !recommendations.contains(where: { $0.id == product.id }) &&
                (product.collection == item.collection || product.brand == item.brand)
            }
            recommendations.append(contentsOf: matched)
        }
        
        // If we have too many, limit them. If too few, add some general ones.
        if recommendations.count > 10 {
            return Array(recommendations.prefix(10))
        } else if recommendations.count < 3 {
            let additional = allProducts.filter { product in
                !cartIds.contains(product.id) &&
                !recommendations.contains(where: { $0.id == product.id })
            }
            recommendations.append(contentsOf: additional.prefix(5 - recommendations.count))
        }
        
        return recommendations
    }
    
    /// Suggest substitutions for out-of-stock items
    func getSubstitutions(for product: ProductItem, from allProducts: [ProductItem]) -> [ProductItem] {
        return allProducts.filter { other in
            other.id != product.id &&
            other.productType == product.productType &&
            other.availability == "ON_HAND"
        }
    }
}
