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
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
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
            .cornerRadius(12)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(2)
                    .frame(height: 32, alignment: .topLeading)
                
                HStack {
                    Text(product.price?.formatted(.currency(code: "USD")) ?? "")
                        .font(.system(size: 12, weight: .bold))
                    
                    Spacer()
                    
                    Button(action: {
                        haptic.impactOccurred()
                        onAdd(product)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
        .padding(8)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}
