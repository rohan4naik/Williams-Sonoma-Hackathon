//
//  SmartRecommendationService.swift
//  WSHackathonApp
//

import Foundation

@MainActor
final class SmartRecommendationService {
    
    static let shared = SmartRecommendationService()
    private init() {}

    // MARK: - Complete the Collection
    // Purpose: Premium curated lifestyle bundle — scored by collection & brand relevance.
    // Guarantee: Always returns 2–5 products. Dynamically re-scores on every cart change.
    func generateCompleteCollection(for cartItems: [CartItem], from allProducts: [ProductItem]) -> [ProductItem] {
        guard !cartItems.isEmpty else {
            return Array(allProducts.prefix(5))
        }

        let cartIds = Set(cartItems.map { $0.id })
        var scored: [(product: ProductItem, score: Int)] = []

        for product in allProducts {
            guard !cartIds.contains(product.id) else { continue }

            var score = 0
            for cartItem in cartItems {
                // Same collection = strongest curation signal
                if let pc = product.collection, let ic = cartItem.collection, pc == ic {
                    score += 3
                }
                // Same brand = premium lifestyle relevance
                if let pb = product.brand, let ib = cartItem.brand, pb == ib {
                    score += 2
                }
            }

            if score > 0 {
                scored.append((product, score))
            }
        }

        let sorted = scored
            .sorted { $0.score > $1.score }
            .map { $0.product }

        var results = Array(sorted.prefix(5))

        // Fallback: if fewer than 2, fill with any non-cart products
        if results.count < 2 {
            let fallback = allProducts.filter { product in
                !cartIds.contains(product.id) &&
                !results.contains(where: { $0.id == product.id })
            }
            results.append(contentsOf: fallback.prefix(max(0, 3 - results.count)))
        }

        return results
    }

    // MARK: - Frequently Bought Together
    // Purpose: Practical utility companions — scored independently, never overlaps with collection picks.
    // Guarantee: Always returns 2–5 unique products, none from completeCollection results.
    func generateFrequentlyBoughtTogether(for cartItems: [CartItem], from allProducts: [ProductItem], excluding collectionPicks: [ProductItem]) -> [ProductItem] {
        guard !cartItems.isEmpty else {
            return Array(allProducts.dropFirst(5).prefix(5))
        }

        let cartIds = Set(cartItems.map { $0.id })
        let excludedIds = Set(collectionPicks.map { $0.id }).union(cartIds)
        var scored: [(product: ProductItem, score: Int)] = []

        for product in allProducts {
            guard !excludedIds.contains(product.id) else { continue }

            var score = 0
            for cartItem in cartItems {
                // Same brand, different collection = practical cross-sell
                if let pb = product.brand, let ib = cartItem.brand, pb == ib {
                    score += 2
                    if let pc = product.collection, let ic = cartItem.collection, pc != ic {
                        score += 1  // extra bonus for cross-collection variety
                    }
                }
                // productType match via ProductItem-to-ProductItem is not possible here (CartItem has no productType)
                // Use title keyword overlap as a lightweight heuristic
                let cartWords = Set(cartItem.title.lowercased().split(separator: " ").map(String.init))
                let prodWords = Set(product.title.lowercased().split(separator: " ").map(String.init))
                let overlap = cartWords.intersection(prodWords).count
                if overlap > 0 { score += overlap }
            }

            if score > 0 {
                scored.append((product, score))
            }
        }

        let sorted = scored
            .sorted { $0.score > $1.score }
            .map { $0.product }

        var results = Array(sorted.prefix(5))

        // Fallback: ensure minimum 2
        if results.count < 2 {
            let fallback = allProducts.filter { product in
                !excludedIds.contains(product.id) &&
                !results.contains(where: { $0.id == product.id })
            }
            results.append(contentsOf: fallback.prefix(max(0, 3 - results.count)))
        }

        return results
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
