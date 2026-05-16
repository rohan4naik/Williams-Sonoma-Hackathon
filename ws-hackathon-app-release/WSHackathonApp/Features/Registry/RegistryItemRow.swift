//
//  RegistryItemRow.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//
import SwiftUI

struct RegistryItemRow: View {
    
    @StateObject private var viewModel: RegistryItemRowViewModel
    
    init(viewModel: RegistryItemRowViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            CustomAsyncImage(url: viewModel.imageURL)
                .frame(width: 90, height: 90)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(viewModel.title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(viewModel.priceText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                
                HStack(spacing: 12) {
                    HStack(spacing: 10) {
                        Button(action: viewModel.decreaseQty) {
                            Image(systemName: "minus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 24, height: 24)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        
                        Text(viewModel.quantityText)
                            .font(.system(size: 13, weight: .medium))
                            .frame(minWidth: 16)
                        
                        Button(action: viewModel.increaseQty) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 24, height: 24)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(20)
                }
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: viewModel.addToCart) {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                
                Button(action: viewModel.removeItem) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}
