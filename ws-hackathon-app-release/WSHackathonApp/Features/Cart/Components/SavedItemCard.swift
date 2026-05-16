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
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                CustomAsyncImage(url: item.imageURL)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                Button(action: {
                    haptic.impactOccurred()
                    onRemove()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .padding(10)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.brand?.uppercased() ?? "WILLIAMS SONOMA")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(0.5)
                
                Text(item.title)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(1)
                
                HStack {
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                    
                    Spacer()
                    
                    if item.availability == "ON_HAND" {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            Button(action: {
                haptic.impactOccurred()
                onMoveToCart()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "cart.badge.plus")
                    Text("MOVE TO CART")
                }
                .font(.system(size: 10, weight: .black))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.black)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
}
