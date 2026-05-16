//
//  ProductRepository.swift
//  WSHackathonApp
//

import Foundation
import Combine

@MainActor
final class ProductRepository: ObservableObject {
    @Published var products: [ProductItem] = []
    
    static let shared = ProductRepository()
    private init() {}
    
    func setProducts(_ products: [ProductItem]) {
        self.products = products
    }
}
