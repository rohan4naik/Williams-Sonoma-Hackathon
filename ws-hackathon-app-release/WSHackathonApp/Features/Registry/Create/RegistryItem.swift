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
    var categoryId: UUID? = nil        // nil = uncategorized
    var customCategoryName: String? = nil
    
    init(id: String,
         title: String,
         price: Double,
         imageUrl: String?,
         quantity: Int,
         categoryId: UUID? = nil,
         customCategoryName: String? = nil) {
        self.id = id
        self.title = title
        self.price = price
        self.imageUrl = imageUrl
        self.quantity = quantity
        self.categoryId = categoryId
        self.customCategoryName = customCategoryName
    }
}
