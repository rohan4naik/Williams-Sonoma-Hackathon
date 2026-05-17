//
//  RegistryItem.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation

struct RegistryItem: Identifiable, Hashable, Codable {
    let id: String // productId
    let title: String
    let price: Double
    let imageUrl: String?
    var quantity: Int
    var purchasedQuantity: Int
    var categoryId: UUID? = nil        // nil = uncategorized
    var customCategoryName: String? = nil
    
    init(id: String,
         title: String,
         price: Double,
         imageUrl: String?,
         quantity: Int,
         purchasedQuantity: Int = 0,
         categoryId: UUID? = nil,
         customCategoryName: String? = nil) {
        self.id = id
        self.title = title
        self.price = price
        self.imageUrl = imageUrl
        self.quantity = quantity
        self.purchasedQuantity = purchasedQuantity
        self.categoryId = categoryId
        self.customCategoryName = customCategoryName
    }
    
    var imageURL: URL? {
        guard let url = imageUrl else { return nil }
        if url.contains("example.com") || url.contains("placeholder") || url.isEmpty {
            let cleanQuery = title
                .lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty && $0.count > 2 }
                .joined(separator: ",")
            return URL(string: "https://loremflickr.com/600/600/\(cleanQuery.isEmpty ? "kitchen" : cleanQuery)")
        }
        if url.hasPrefix("http://") || url.hasPrefix("https://") {
            return URL(string: url)
        }
        return URL(string: AppConstants.API.imageBasePath + url)
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, imageUrl, quantity, purchasedQuantity, categoryId, customCategoryName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.price = try container.decode(Double.self, forKey: .price)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        self.purchasedQuantity = try container.decodeIfPresent(Int.self, forKey: .purchasedQuantity) ?? 0
        self.categoryId = try container.decodeIfPresent(UUID.self, forKey: .categoryId)
        self.customCategoryName = try container.decodeIfPresent(String.self, forKey: .customCategoryName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(price, forKey: .price)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(purchasedQuantity, forKey: .purchasedQuantity)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        try container.encodeIfPresent(customCategoryName, forKey: .customCategoryName)
    }
}
