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
    
    @State private var showProfile = false
    
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
                                        CategoryCapsule(name: "New", icon: "sparkles", color: Color.cyan.opacity(0.15))
                                        CategoryCapsule(name: "Cookware", icon: "frying.pan", color: Color.gray.opacity(0.15))
                                        CategoryCapsule(name: "Cooks' Tools", icon: "timer", color: Color.teal.opacity(0.15))
                                        CategoryCapsule(name: "Cutlery", icon: "fork.knife", color: Color.gray.opacity(0.2))
                                        CategoryCapsule(name: "Electrics", icon: "bolt.fill", color: Color.yellow.opacity(0.2))
                                        CategoryCapsule(name: "Bakeware", icon: "oven", color: Color.brown.opacity(0.15))
                                        CategoryCapsule(name: "Food", icon: "carrot.fill", color: Color.orange.opacity(0.2))
                                        CategoryCapsule(name: "Tabletop & Bar", icon: "wineglass", color: Color.purple.opacity(0.15))
                                        CategoryCapsule(name: "Home Essentials", icon: "house.fill", color: Color.blue.opacity(0.15))
                                        CategoryCapsule(name: "Outdoor & Garden", icon: "leaf.fill", color: Color.green.opacity(0.15))
                                        CategoryCapsule(name: "Furniture", icon: "sofa.fill", color: Color.indigo.opacity(0.15))
                                        CategoryCapsule(name: "Holidays", icon: "party.popper.fill", color: Color.pink.opacity(0.15))
                                        CategoryCapsule(name: "Gifts", icon: "gift.fill", color: Color.yellow.opacity(0.15))
                                        CategoryCapsule(name: "Sale", icon: "tag.fill", color: Color.red.opacity(0.2))
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
                                        ForEach(Array(viewModel.products.prefix(5).enumerated()), id: \.element.id) { index, product in
                                            NavigationLink(destination: ProductDetailView(product: product, relatedProducts: Array(viewModel.products.shuffled().prefix(6)))) {
                                                MostLovedCard(product: product, index: index)
                                            }
                                            .buttonStyle(PlainButtonStyle())
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
                                    NavigationLink(destination: ProductDetailView(product: product, relatedProducts: Array(viewModel.products.shuffled().prefix(6)))) {
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
                                    .buttonStyle(PlainButtonStyle())
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showProfile = true }) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 34, height: 34)
                            Text("KK")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileSheetView(isPresented: $showProfile)
                    .environmentObject(cartRepository)
                    .environmentObject(registryRepository)
                    .environmentObject(tabBarVM)
            }
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
    let index: Int
    
    let colors: [Color] = [
        Color(red: 0.96, green: 0.94, blue: 0.92), // Warm beige
        Color(red: 0.92, green: 0.94, blue: 0.93), // Cool mint
        Color(red: 0.94, green: 0.93, blue: 0.95), // Soft lavender
        Color(red: 0.96, green: 0.93, blue: 0.93), // Soft pink
        Color(red: 0.93, green: 0.95, blue: 0.96)  // Soft blue
    ]
    
    var body: some View {
        let bgColor = colors[index % colors.count]
        let rating = 4.5 + Double(index % 5) * 0.1 // Just for visual variety
        
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.black)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Star Rating
                HStack(spacing: 2) {
                    ForEach(0..<5) { star in
                        Image(systemName: star < 4 ? "star.fill" : (rating > 4.8 ? "star.fill" : "star.leadinghalf.filled"))
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                    Text(String(format: "(%.1f)", rating))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.5))
                        .padding(.leading, 2)
                }
                
                Spacer(minLength: 8)
                
                Text(product.price?.formatted(.currency(code: "USD")) ?? "")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.black)
            }
            .padding(.vertical, 24)
            .padding(.leading, 24)
            
            Spacer()
            
            AsyncImage(url: product.imageURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 90, height: 90)
            .clipped()
            .padding(.trailing, 24)
        }
        .frame(width: 300, height: 140)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}

struct CategoryCapsule: View {
    let name: String
    let icon: String
    var color: Color = Color(.systemBackground)
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
            
            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 85)
    }
}
