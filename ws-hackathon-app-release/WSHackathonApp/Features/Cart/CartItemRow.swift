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
        HStack(alignment: .top, spacing: 12) {
            let url = item.imageURL
            // MARK: - Image
            CustomAsyncImage(url: url)
                .frame(width: 90, height: 90)
                .cornerRadius(10)
                .clipped()
            
            // MARK: - Info
            VStack(alignment: .leading, spacing: 6) {
                
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                // Availability Nudge
                if item.availability == "BACK_ORDERED" {
                    HStack {
                        Text("BACKORDERED")
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                        
                        Text("Suggest moving to Save for Later")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                } else if item.availability == "NLA" {
                    Text("NO LONGER AVAILABLE")
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                        .padding(.vertical, 2)
                }
                
                if item.canGiftWrap {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .foregroundColor(.pink)
                            .font(.caption2)
                        Text("Gift wrapping available")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                // MARK: - Actions
                HStack(spacing: 16) {
                    // Quantity Controls
                    HStack(spacing: 12) {
                        Button(action: {
                            haptic.impactOccurred()
                            onRemove()
                        }) {
                            Image(systemName: "minus.circle.fill")
                        }
                        
                        Text("\(item.quantity)")
                            .font(.subheadline.monospacedDigit())
                            .fontWeight(.semibold)
                            .frame(minWidth: 24)
                        
                        Button(action: {
                            haptic.impactOccurred()
                            onAdd()
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .font(.title3)
                    .foregroundColor(.black)
                    
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 1, height: 16)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            haptic.impactOccurred()
                            onSaveForLater()
                        }) {
                            Image(systemName: "heart")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            haptic.impactOccurred()
                            onDelete()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
