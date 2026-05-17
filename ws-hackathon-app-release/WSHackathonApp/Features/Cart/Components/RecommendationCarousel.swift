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
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .default))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(products) { product in
                        RecommendationCard(product: product, onAdd: onAdd)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .padding(.vertical, 12)
    }
}

struct RecommendationCard: View {
    let product: ProductItem
    let onAdd: (ProductItem) -> Void
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // TOP: Large product image (Hero)
            CustomAsyncImage(url: product.imageURL)
                .frame(width: 156, height: 156)
                .aspectRatio(contentMode: .fill)
                .clipped()
            
            VStack(alignment: .leading, spacing: 10) {
                // MIDDLE: Product title (2 lines max)
                Text(product.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 34, alignment: .top)
                
                // BOTTOM: Price and Small elegant add button
                HStack(alignment: .bottom) {
                    Text(product.price?.formatted(.currency(code: "USD")) ?? "")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        haptic.impactOccurred()
                        onAdd(product)
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(width: 22, height: 22)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        .frame(width: 156)
    }
}
