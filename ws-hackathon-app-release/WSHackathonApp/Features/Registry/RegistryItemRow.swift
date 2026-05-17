//
//  RegistryItemRow.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//
import SwiftUI

struct RegistryItemRow: View {
    
    @ObservedObject private var viewModel: RegistryItemRowViewModel
    
    init(viewModel: RegistryItemRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: 16) {
            CustomAsyncImage(url: viewModel.imageURL)
                .frame(width: 110, height: 110)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .padding(.leading, 12)
                .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.title)
                    .font(.system(size: 16, weight: .regular))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .padding(.top, 12)
                
                Text(viewModel.priceText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                if viewModel.purchasedProgress > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(viewModel.purchasedQuantity) of \(viewModel.requestedQuantity) funded")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color(.systemGray6)).frame(height: 6)
                                Capsule().fill(Color.green).frame(width: geo.size.width * CGFloat(viewModel.purchasedProgress), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                    .padding(.top, 4)
                    .padding(.trailing, 16)
                }
                
                Spacer(minLength: 8)
                
                HStack(alignment: .center) {
                    // Quantity selector
                    if !viewModel.isFullyFunded {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 16) {
                                Button(action: viewModel.decreaseQty) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                
                                Text(viewModel.quantityText)
                                    .font(.system(size: 14, weight: .semibold))
                                    .frame(minWidth: 16)
                                
                                Button(action: viewModel.increaseQty) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            
                            if viewModel.isCollaborator && !viewModel.canActDirectly {
                                Text("Changes require owner approval")
                                    .font(.system(size: 10))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 4)
                            }
                        }
                    } else {
                        // Fully Paid checkmark badge
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.green)
                            Text("Fully Paid")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.12))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    if viewModel.isFullyFunded {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.green)
                            .padding(.trailing, 16)
                    } else {
                        Button(action: viewModel.addToCart) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 22))
                                .foregroundColor(.black)
                        }
                        .padding(.trailing, viewModel.canActDirectly && viewModel.totalContributed == 0 ? 8 : 16)
                        
                        if viewModel.canActDirectly && viewModel.totalContributed == 0 {
                            Button(action: viewModel.removeItem) {
                                Image(systemName: "trash")
                                    .font(.system(size: 22))
                                    .foregroundColor(.red)
                            }
                            .padding(.trailing, 16)
                        }
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .opacity(viewModel.isFullyFunded ? 0.5 : 1.0)
        .grayscale(viewModel.isFullyFunded ? 1.0 : 0.0)
        .disabled(viewModel.isFullyFunded)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}
