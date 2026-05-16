//
//  HomeView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground) // More native background color
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // MARK: - Hero Section
                            if viewModel.searchText.isEmpty {
                                HeroBannerView()
                                    .padding(.bottom, 32)
                            } else {
                                // Results header for search
                                Text("Search Results")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                    .padding(.bottom, 16)
                            }
                            
                            if viewModel.searchText.isEmpty {
                                // MARK: - Categories
                                Text("Shop by Category")
                                    .font(.title3.bold())
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        CategoryCapsule(name: "Cookware", icon: "frying.pan")
                                        CategoryCapsule(name: "Bakeware", icon: "oven")
                                        CategoryCapsule(name: "Cutlery", icon: "fork.knife")
                                        CategoryCapsule(name: "Electrics", icon: "bolt.fill")
                                        CategoryCapsule(name: "Tabletop", icon: "wineglass")
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.bottom, 32)
                                
                                Text("Most Loved")
                                    .font(.title3.bold())
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(viewModel.products.prefix(5)) { product in
                                            MostLovedCard(product: product)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.bottom, 32)
                                
                                Text("Explore All")
                                    .font(.title3.bold())
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                            }
                            
                            // MARK: - Product Grid
                            let spacing: CGFloat = 16
                            let columns = [
                                GridItem(.flexible(), spacing: spacing),
                                GridItem(.flexible(), spacing: spacing)
                            ]
                            
                            LazyVGrid(columns: columns, spacing: spacing) {
                                ForEach(viewModel.filteredProducts) { product in
                                    ProductCardView(
                                        product: product,
                                        quantity: viewModel.quantity(for: product),
                                        registryQuantity: viewModel.registryQuantity(for: product),
                                        onAdd: { viewModel.addToCart(product) },
                                        onRemove: { viewModel.removeFromCart(product) },
                                        onAddToRegistry: {
                                            if viewModel.canAddToRegistry(product) {
                                                viewModel.addToRegistry(product)
                                            } else {
                                                tabBarVM.selectTab(.registry)
                                            }                                            
                                        },
                                        onRemoveFromRegistry: { viewModel.removeFromRegistry(product) }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
            .navigationTitle(AppStrings.Home.title)
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: AppStrings.Home.searchPlaceHolder)
            .onAppear {
                Task {
                    viewModel.bind(
                        cartRepository: cartRepository,
                        registryRepository: registryRepository
                    )
                    await viewModel.fetchProducts()
                }
            }
        }
    }
}

struct MostLovedCard: View {
    let product: ProductItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: product.imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Color.gray.opacity(0.1)
                    }
                }
                .frame(width: 280, height: 180)
                .clipped()
                .cornerRadius(4)
                
                // Floating Badge
                Text("Bestseller")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(2)
                    .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .lineLimit(1)
                
                Text(product.price?.formatted(.currency(code: "USD")) ?? "")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 280)
    }
}

struct CategoryCapsule: View {
    let name: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
            
            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}
