//
//  RecommendationCarousel.swift
//  WSHackathonApp
//

import SwiftUI

struct RecommendationCarousel: View {
    let title: String
    let products: [ProductItem]
    let onAdd: (ProductItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(products) { product in
                        RecommendationCard(product: product, onAdd: onAdd)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
}

struct RecommendationCard: View {
    let product: ProductItem
    let onAdd: (ProductItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: product.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color(.systemGray6)
            }
            .frame(width: 140, height: 140)
            .cornerRadius(8)
            
            Text(product.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(height: 35, alignment: .topLeading)
            
            HStack {
                Text(product.price?.formatted(.currency(code: "USD")) ?? "")
                    .font(.caption)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { onAdd(product) }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.black)
                        .font(.title3)
                }
            }
        }
        .frame(width: 140)
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
