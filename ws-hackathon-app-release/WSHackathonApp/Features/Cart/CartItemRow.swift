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
                    Text("Backordered: Suggest moving to Save for Later")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.vertical, 2)
                } else if item.availability == "NLA" {
                    Text("No longer available. Please remove.")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(.vertical, 2)
                }
                
                if item.canGiftWrap {
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundColor(.pink)
                        Text("Gift wrapping available")
                            .font(.caption2)
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
                            .fontWeight(.medium)
                            .frame(minWidth: 20)
                        
                        Button(action: {
                            haptic.impactOccurred()
                            onAdd()
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    .font(.title3)
                    .foregroundColor(.black)
                    
                    Divider().frame(height: 20)
                    
                    Button(action: {
                        haptic.impactOccurred()
                        onSaveForLater()
                    }) {
                        Image(systemName: "heart")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        haptic.impactOccurred()
                        onDelete()
                    }) {
                        Image(systemName: "trash")
                            .font(.body)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
