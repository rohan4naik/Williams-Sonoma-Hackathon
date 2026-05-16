//
//  CartView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            // MARK: - Free Shipping Progress
                            if !viewModel.items.isEmpty {
                                SmartProgressBar(currentTotal: cartRepository.totalPrice)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                            }
                            
                            // MARK: - Cart Items
                            if viewModel.items.isEmpty {
                                EmptyCartView()
                                    .padding(.top, 20)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.items) { item in
                                        CartItemRow(
                                            item: item,
                                            onAdd: { viewModel.add(item) },
                                            onRemove: { viewModel.removeItem(item) },
                                            onSaveForLater: { viewModel.saveForLater(item) },
                                            onDelete: { viewModel.deleteItem(item) }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // MARK: - Recommendations
                            if !viewModel.recommendations.isEmpty {
                                RecommendationCarousel(
                                    title: viewModel.items.isEmpty ? "Suggested for You" : "Complete the Collection",
                                    products: viewModel.recommendations,
                                    onAdd: { product in
                                        viewModel.addToCart(product: product)
                                    }
                                )
                            }
                            
                            // MARK: - Best Sellers
                            if !viewModel.bestSellers.isEmpty {
                                RecommendationCarousel(
                                    title: "Best Sellers",
                                    products: viewModel.bestSellers,
                                    onAdd: { product in
                                        viewModel.addToCart(product: product)
                                    }
                                )
                            }
                            
                            // MARK: - Recently Viewed
                            if !viewModel.recentlyViewed.isEmpty {
                                RecommendationCarousel(
                                    title: "Recently Viewed",
                                    products: viewModel.recentlyViewed,
                                    onAdd: { product in
                                        viewModel.addToCart(product: product)
                                    }
                                )
                            }
                            
                            // MARK: - Save for Later
                            if !viewModel.savedItems.isEmpty {
                                Divider().padding(.horizontal)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Save for Later (\(viewModel.savedItems.count))")
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        Text("Moving items?")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    
                                    let columns = [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ]
                                    
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        ForEach(viewModel.savedItems) { item in
                                            SavedItemCard(
                                                item: item,
                                                onMoveToCart: { viewModel.moveToCart(item) },
                                                onRemove: { viewModel.removeFromSaved(item) }
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            Spacer().frame(height: 100)
                        }
                    }
                    
                    // MARK: - Footer Actions
                    if !viewModel.items.isEmpty {
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Subtotal")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(viewModel.totalPriceText)
                                }
                                
                                HStack {
                                    Text("Shipping")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(cartRepository.totalPrice >= 150 ? "FREE" : "$15.00")
                                        .foregroundColor(cartRepository.totalPrice >= 150 ? .green : .primary)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Total")
                                        .font(.headline)
                                    Spacer()
                                    Text("$\(cartRepository.totalPrice + (cartRepository.totalPrice >= 150 ? 0 : 15), specifier: "%.2f")")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            Button(action: {
                                let haptic = UIImpactFeedbackGenerator(style: .heavy)
                                haptic.impactOccurred()
                                // Simulate checkout
                            }) {
                                HStack {
                                    Text("Checkout")
                                    Image(systemName: "arrow.right")
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: -5)
                    } else {
                        Button(action: {
                            let haptic = UIImpactFeedbackGenerator(style: .medium)
                            haptic.impactOccurred()
                            tabBarVM.selectTab(.home)
                        }) {
                            Text(AppStrings.Cart.emptyButton)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: -5)
                    }
                }
            }
            .navigationTitle("Smart Cart")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.bind(repository: cartRepository)
        }
    }
}
