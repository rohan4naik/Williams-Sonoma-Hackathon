//
//  CartItemRow.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import SwiftUI

struct CartItemRow: View {
    
    let item: CartItem
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onSaveForLater: () -> Void
    let onDelete: () -> Void
    
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Card
            HStack(spacing: 0) {
                // Left: Image with specific corner radius
                CustomAsyncImage(url: item.imageURL)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(12)
                
                // Center: Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            Text("LARGE • 4.5 LITRE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Tag box (simulating the "Brushed Copper" tag)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("BRUSHED")
                            Text("COPPER")
                        }
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(Color(red: 0.5, green: 0.6, blue: 0.5))
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color(red: 0.5, green: 0.6, blue: 0.5).opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.trailing, 12)
                
                // Right: Vertical Price Section
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 1)
                        .padding(.vertical, 20)
                    
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(90))
                        .fixedSize()
                        .frame(width: 50)
                }
            }
            .background(Color(red: 0.11, green: 0.11, blue: 0.11))
            .cornerRadius(35)
            .overlay(
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            haptic.impactOccurred()
                            onSaveForLater()
                        }) {
                            Image(systemName: "heart")
                                .font(.system(size: 12))
                                .foregroundColor(.blue.opacity(0.8))
                        }
                        .padding(8)
                        
                        Button(action: {
                            haptic.impactOccurred()
                            onDelete()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(8)
                    }
                }
                .padding(.trailing, 60) // Positioned before the price section
                , alignment: .topTrailing
            )
            
            // Bottom: Floating Quantity Control
            HStack(spacing: 20) {
                Button(action: {
                    haptic.impactOccurred()
                    onRemove()
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }
                
                Text(String(format: "%02d", item.quantity))
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Button(action: {
                    haptic.impactOccurred()
                    onAdd()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(Color(red: 0.18, green: 0.18, blue: 0.18))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
            .offset(y: 18)
        }
        .padding(.bottom, 25)
        .padding(.horizontal, 16)
    }
}
