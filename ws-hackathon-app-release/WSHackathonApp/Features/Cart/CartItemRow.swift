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
                VStack(alignment: .leading, spacing: 6) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.brand?.uppercased() ?? "WILLIAMS SONOMA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(1)
                        
                        Text(item.title)
                            .font(.system(size: 16, weight: .bold))
                            .lineLimit(2)
                            .foregroundColor(.primary)
                        
                        Text("$\(item.price, specifier: "%.2f")")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // MARK: - Bottom Actions Row
                    HStack(spacing: 16) {
                        // Quantity Pill
                        HStack(spacing: 12) {
                            Button(action: {
                                haptic.impactOccurred()
                                onRemove()
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            
                            Text("\(item.quantity)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .frame(minWidth: 16)
                            
                            Button(action: {
                                haptic.impactOccurred()
                                onAdd()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        // Bookmark & Delete
                        HStack(spacing: 18) {
                            Button(action: {
                                haptic.impactOccurred()
                                onSaveForLater()
                            }) {
                                Image(systemName: "bookmark")
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                            }
                            
                            Button(action: {
                                haptic.impactOccurred()
                                onDelete()
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.trailing, 16)
            }
            .frame(height: 150)
        }
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
}
