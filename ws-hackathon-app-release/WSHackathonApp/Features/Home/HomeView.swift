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
                                        ForEach([
                                            ("New",            "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/tea_set_1779007540759.png"),
                                            ("Cookware",       "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/dutch_oven_1779007363974.png"),
                                            ("Cooks' Tools",   "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/utensils_1779007398920.png"),
                                            ("Cutlery",        "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/chef_knife_1779007379223.png"),
                                            ("Electrics",      "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/pizza_oven_1779007606970.png"),
                                            ("Bakeware",       "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/baking_sheet_1779007429395.png"),
                                            ("Food",           "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80"),
                                            ("Tabletop & Bar", "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/wine_glasses_1779007476041.png"),
                                            ("Home Essentials","file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/candlesticks_1779007574028.png"),
                                            ("Outdoor",        "https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?q=80&w=400&auto=format&fit=crop"),
                                            ("Furniture",      "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/dining_table_1779007460233.png"),
                                            ("Holidays",       "https://images.unsplash.com/photo-1545048702-79362596cdc9?q=80&w=400&auto=format&fit=crop"),
                                            ("Gifts",          "https://images.unsplash.com/photo-1549465220-1a8b9238cd48?q=80&w=400&auto=format&fit=crop"),
                                            ("Sale",           "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?q=80&w=400&auto=format&fit=crop")
                                        ], id: \.0) { name, imageUrl in
                                            NavigationLink(destination:
                                                CategoryDetailView(
                                                    categoryName: name,
                                                    allProducts: viewModel.products
                                                )
                                            ) {
                                                CategoryCard(name: name, imageUrl: imageUrl)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                }
                                .padding(.bottom, 24)
                                
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
                                    .padding(.vertical, 10)
                                }
                                .padding(.bottom, 22)
                                
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
                        .frame(width: 90, height: 90)
                        .clipped()
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                        .frame(width: 90, height: 90)
                } else {
                    ProgressView()
                        .frame(width: 90, height: 90)
                }
            }
            .padding(.trailing, 24)
        }
        .frame(width: 300, height: 140)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 2)
    }
}

struct CategoryCard: View {
    let name: String
    let imageUrl: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                CustomAsyncImage(url: URL(string: imageUrl))
                    .frame(width: 118, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                // Native iOS-style chevron badge
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(6)
                    .background(.ultraThinMaterial, in: Circle())
                    .padding(8)
            }
            .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 2)
            
            Text(name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 118)
    }
}
