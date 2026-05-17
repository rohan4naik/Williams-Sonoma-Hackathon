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
        HStack(spacing: 0) {
            // MARK: - Product Image
            CustomAsyncImage(url: item.imageURL)
                .frame(width: 120, height: 120)
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(12)
            
            // MARK: - Details Section
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(item.title)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .padding(.top, 16)
                
                // Price
                let itemContributions = CollaborationManager.shared.contributions
                    .filter { $0.itemId == item.id }
                let totalContributed = itemContributions.reduce(0.0) { $0 + $1.amount }
                let remainingPrice = max(0.0, item.price - totalContributed)
                
                HStack(spacing: 8) {
                    Text("$\(remainingPrice, specifier: "%.2f")")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if totalContributed > 0 {
                        Text("($\(item.price, specifier: "%.2f") - $\(totalContributed, specifier: "%.2f") contri)")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                            .lineLimit(1)
                    }
                }
                .padding(.top, 6)
                
                Spacer()
                
                // MARK: - Bottom Control Row
                HStack(alignment: .center) {
                    // Apple-style Stepper
                    HStack(spacing: 14) {
                        Button(action: {
                            haptic.impactOccurred()
                            onRemove()
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("\(item.quantity)")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .frame(minWidth: 14)
                        
                        Button(action: {
                            haptic.impactOccurred()
                            onAdd()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            haptic.impactOccurred()
                            onSaveForLater()
                        }) {
                            Image(systemName: item.isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            haptic.impactOccurred()
                            onDelete()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.trailing, 4)
                }
                .padding(.bottom, 16)
            }
            .padding(.trailing, 16)
        }
        .frame(height: 150)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
}
