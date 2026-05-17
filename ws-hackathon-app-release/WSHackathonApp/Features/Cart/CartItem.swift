//
//  CartItem.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
struct CartItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let price: Double
    let path: String?
    let brand: String?
    let collection: String?
    let availability: String?
    let canGiftWrap: Bool
    var quantity: Int
    var isSaved: Bool = false
    
    // Smart Insights for saved items
    var priceDropText: String? = nil
    var lowStockText: String? = nil
    var isPopular: Bool? = false
    
    var imageURL: URL? {
        ProductImageResolver.resolveImageURL(forTitle: title, path: path)
    }

    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id
    }
}
