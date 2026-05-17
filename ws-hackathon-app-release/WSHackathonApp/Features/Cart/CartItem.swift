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
    
    var imageURL: URL? {
        if let imageUrl = path {
            if imageUrl.contains("example.com") || imageUrl.contains("placeholder") || imageUrl.isEmpty {
                let cleanQuery = title
                    .lowercased()
                    .components(separatedBy: CharacterSet.alphanumerics.inverted)
                    .filter { !$0.isEmpty && $0.count > 2 }
                    .joined(separator: ",")
                return URL(string: "https://loremflickr.com/600/600/\(cleanQuery.isEmpty ? "kitchen" : cleanQuery)")
            }
            if imageUrl.hasPrefix("http://") || imageUrl.hasPrefix("https://") {
                return URL(string: imageUrl)
            }
            return URL(string: AppConstants.API.imageBasePath + imageUrl)
        }
        return nil
    }

    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id
    }
}
