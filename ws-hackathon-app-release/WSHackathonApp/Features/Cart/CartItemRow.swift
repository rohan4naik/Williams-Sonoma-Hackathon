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
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.brand?.uppercased() ?? "WILLIAMS SONOMA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(1)
                        
                        Text(item.title)
                            .font(.system(size: 16, weight: .bold))
                            .lineLimit(2)
                            .foregroundColor(.primary)
                        
                        if let collection = item.collection {
                            Text(collection)
                                .font(.system(size: 9, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    // MARK: - Quantity Pill (Moved here)
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
                    
                    if item.availability == "BACK_ORDERED" {
                        Text("BACKORDERED")
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 16)
                .padding(.trailing, 8)
                
                Spacer()
                
                // MARK: - Vertical Price & Actions
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 1)
                        .padding(.vertical, 20)
                    
                    VStack(spacing: 12) {
                        Text("$\(item.price, specifier: "%.2f")")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .rotationEffect(.degrees(-90))
                            .fixedSize()
                            .frame(width: 40, height: 60)
                        
                        Spacer()
                        
                        VStack(spacing: 16) {
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
                        .padding(.bottom, 16)
                    }
                    .frame(width: 50)
                }
            }
            .frame(height: 160)
        }
        .background(Color.white)
        .cornerRadius(28)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
}
