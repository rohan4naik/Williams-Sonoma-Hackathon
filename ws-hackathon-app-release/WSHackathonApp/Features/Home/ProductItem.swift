//
//  ProductItem.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 05/04/26.
//

import Foundation
struct ProductItem: Identifiable, Equatable {
    let id: String
    let title: String
    let price: Double?
    let path: String?
    let brand: String?
    let productType: String?
    let collection: String?
    let availability: String?
    let canGiftWrap: Bool
    
    init(id: String,
         title: String,
         price: Double?,
         path: String?,
         brand: String? = nil,
         productType: String? = nil,
         collection: String? = nil,
         availability: String? = "ON_HAND",
         canGiftWrap: Bool = false) {
        self.id = id
        self.title = title
        self.price = price
        self.path = path
        self.brand = brand
        self.productType = productType
        self.collection = collection
        self.availability = availability
        self.canGiftWrap = canGiftWrap
    }
    
    var imageURL: URL? {
        if let imageUrl = path {
            return URL(string: AppConstants.API.imageBasePath + imageUrl)
        }
        return nil
    }

    static func == (lhs: ProductItem, rhs: ProductItem) -> Bool {
        lhs.id == rhs.id
    }
}

extension ProductItem {
    init(from dto: ProductItemDTO) {
        self.id = dto.id
        self.title = dto.name.replacingOccurrences(of: "Williams Sonoma ", with: "")
        self.brand = dto.properties?.brand
        self.productType = dto.properties?.productType
        self.collection = dto.properties?.collection
        self.availability = dto.availability
        self.canGiftWrap = dto.properties?.canGiftWrap == "true"
        
        // Price formatting: use sellingPrice if available, else regularPrice
        if let sellingPrice = dto.price?.sellingPrice {
            self.price = sellingPrice
        } else if let regularPrice = dto.price?.regularPrice {
            self.price = regularPrice
        } else {
            self.price = 0.0
        }
        
        // Image: first ProductImage path if available
        if let firstImage = dto.media?.images?.first?.path {
            self.path = firstImage
        } else {
            self.path = nil
        }
    }
}
