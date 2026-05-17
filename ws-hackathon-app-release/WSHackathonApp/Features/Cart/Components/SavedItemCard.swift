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
        VStack(alignment: .leading, spacing: 0) {
            // TOP: Product Image (Flush)
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .topTrailing) {
                    CustomAsyncImage(url: item.imageURL)
                        .frame(height: 160)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                    
                    // TOP RIGHT: Subtle Remove Icon
                    Button(action: {
                        haptic.impactOccurred()
                        onRemove()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(7)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .padding(10)
                    }
                }
                
                // TOP LEFT: Smart Badges Overlay
                Group {
                    if let priceDrop = item.priceDropText {
                        badgeView(text: priceDrop, icon: "arrow.down.forward", fgColor: Color(.systemGreen))
                    } else if let lowStock = item.lowStockText {
                        badgeView(text: lowStock, icon: "exclamationmark.triangle.fill", fgColor: Color(.systemOrange))
                    } else if item.isPopular == true {
                        badgeView(text: "Popular", icon: "flame.fill", fgColor: Color(.systemIndigo))
                    }
                }
                .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // MIDDLE: Product Title
                Text(item.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(height: 34, alignment: .top)
                
                // Price
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer().frame(height: 4)
                
                // BOTTOM: Elegant Move to Cart Button
                Button(action: {
                    haptic.impactOccurred()
                    onMoveToCart()
                }) {
                    Text("Move to Cart")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
    
    @ViewBuilder
    private func badgeView(text: String, icon: String, fgColor: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text(text)
                .font(.system(size: 9, weight: .bold, design: .default))
        }
        .foregroundColor(fgColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(fgColor.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: text)
    }
}
