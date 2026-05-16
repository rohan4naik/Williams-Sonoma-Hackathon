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
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                // MARK: - Product Image
                CustomAsyncImage(url: item.imageURL)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(12)
                
                // MARK: - Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.brand?.uppercased() ?? "WILLIAMS SONOMA")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .tracking(1)
                    
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        if let collection = item.collection {
                            Text(collection)
                                .font(.system(size: 9, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        if item.canGiftWrap {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.pink)
                        }
                    }
                    
                    Spacer()
                    
                    // Availability
                    if item.availability == "BACK_ORDERED" {
                        Text("BACKORDERED")
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 16)
                .padding(.trailing, 8)
                
                Spacer()
                
                // MARK: - Vertical Price Tag
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 1)
                    .padding(.vertical, 20)
                
                VStack {
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .rotationEffect(.degrees(-90))
                        .fixedSize()
                        .frame(width: 40)
                }
                .padding(.trailing, 8)
            }
            .frame(height: 140)
            
            // MARK: - Bottom Controls
            HStack {
                // Quantity Pill
                HStack(spacing: 15) {
                    Button(action: {
                        haptic.impactOccurred()
                        onRemove()
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                    }
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .frame(minWidth: 20)
                    
                    Button(action: {
                        haptic.impactOccurred()
                        onAdd()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        haptic.impactOccurred()
                        onSaveForLater()
                    }) {
                        Image(systemName: "heart")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        haptic.impactOccurred()
                        onDelete()
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    }
                }
                .padding(.trailing, 16)
            }
            .padding(.bottom, 12)
            .padding(.leading, 12)
        }
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
}
