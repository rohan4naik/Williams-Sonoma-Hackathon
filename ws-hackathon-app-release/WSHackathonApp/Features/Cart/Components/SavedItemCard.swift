//
//  SavedItemCard.swift
//  WSHackathonApp
//

import SwiftUI

struct SavedItemCard: View {
    let item: CartItem
    let onMoveToCart: () -> Void
    let onRemove: () -> Void
    
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                CustomAsyncImage(url: item.imageURL)
                    .frame(height: 120)
                    .cornerRadius(12)
                    .clipped()
                
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.8))
                        .padding(6)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if item.availability == "ON_HAND" {
                    Text("In Stock")
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 4)
            
            Button(action: {
                haptic.impactOccurred()
                onMoveToCart()
            }) {
                HStack {
                    Image(systemName: "cart.badge.plus")
                    Text("Move to Cart")
                }
                .font(.system(size: 10, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
