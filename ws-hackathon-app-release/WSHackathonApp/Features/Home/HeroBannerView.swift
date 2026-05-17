//
//  HeroBannerView.swift
//  WSHackathonApp
//

import SwiftUI

struct HeroItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
    let buttonText: String
    let products: [ProductItem]
}

struct HeroBannerView: View {
    @State private var selection = 0
    
    let items = [
        HeroItem(
            title: "Exclusive Products",
            subtitle: "Discover our hand-selected assortment, available in a range of styles and colors.",
            imageName: "img23m.jpg",
            buttonText: "Explore Collection",
            products: [
                ProductItem(id: "ex_1", title: "All-Clad HA1 Soup Pot 4-Qt.", price: 149.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/soup_pot_1779007332780.png", brand: "All-Clad", productType: "Cookware"),
                ProductItem(id: "ex_2", title: "GreenPan Ceramic Fry Pan Set", price: 89.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/fry_pan_1779007348244.png", brand: "GreenPan", productType: "Cookware"),
                ProductItem(id: "ex_3", title: "Staub Enameled Dutch Oven 5.5-Qt.", price: 299.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/dutch_oven_1779007363974.png", brand: "Staub", productType: "Cookware"),
                ProductItem(id: "ex_4", title: "Damascus Steel Chef's Knife 8\"", price: 159.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/chef_knife_1779007379223.png", brand: "Williams-Sonoma", productType: "Cutlery"),
                ProductItem(id: "ex_5", title: "Olivewood Kitchen Utensil Set", price: 49.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/utensils_1779007398920.png", brand: "Williams-Sonoma", productType: "Tools"),
                ProductItem(id: "ex_6", title: "Le Creuset Signature Saute Pan", price: 189.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/fry_pan_1779007348244.png", brand: "Le Creuset", productType: "Cookware"),
                ProductItem(id: "ex_7", title: "Copper Tri-Ply Skillet 10\"", price: 199.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/fry_pan_1779007348244.png", brand: "Williams-Sonoma", productType: "Cookware"),
                ProductItem(id: "ex_8", title: "Granite Mortar & Pestle", price: 39.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/mortar_pestle_1779007413550.png", brand: "Williams-Sonoma", productType: "Tools"),
                ProductItem(id: "ex_9", title: "Professional Nonstick Baking Sheet", price: 29.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/baking_sheet_1779007429395.png", brand: "Williams-Sonoma", productType: "Bakeware"),
                ProductItem(id: "ex_10", title: "All-Clad Tri-Ply Saucepan 2-Qt.", price: 129.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/fry_pan_1779007348244.png", brand: "All-Clad", productType: "Cookware")
            ]
        ),
        HeroItem(
            title: "Collections",
            subtitle: "Curated sets designed to bring harmony and style to your home.",
            imageName: "shop_collections.png",
            buttonText: "View Collections",
            products: [
                ProductItem(id: "col_1", title: "Stoneware Dinnerware Set (16-Piece)", price: 199.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/dinnerware_1779007444467.png", brand: "Williams-Sonoma", productType: "Tabletop"),
                ProductItem(id: "col_2", title: "Modern Organic Dining Table Setup", price: 899.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/dining_table_1779007460233.png", brand: "Williams-Sonoma", productType: "Furniture"),
                ProductItem(id: "col_3", title: "Handblown Cabernet Wine Glasses (Set of 4)", price: 59.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/wine_glasses_1779007476041.png", brand: "Schott Zwiesel", productType: "Tabletop"),
                ProductItem(id: "col_4", title: "Modern Organic Table Runner", price: 49.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/table_runner_1779007505683.png", brand: "Williams-Sonoma", productType: "Tabletop"),
                ProductItem(id: "col_5", title: "Belgian Linen Tablecloth", price: 119.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/tablecloth_1779007521414.png", brand: "Williams-Sonoma", productType: "Tabletop"),
                ProductItem(id: "col_6", title: "Premium Porcelain Tea Set", price: 79.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/tea_set_1779007540759.png", brand: "Williams-Sonoma", productType: "Tabletop"),
                ProductItem(id: "col_7", title: "Crafted Ceramic Salad Plates (Set of 4)", price: 49.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/salad_plates_1779007557204.png", brand: "Williams-Sonoma", productType: "Tabletop"),
                ProductItem(id: "col_8", title: "Luxe Kitchen Styling Set", price: 159.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/dinnerware_1779007444467.png", brand: "Williams-Sonoma", productType: "Home Essentials"),
                ProductItem(id: "col_9", title: "Minimalist Brass Candlesticks", price: 34.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/candlesticks_1779007574028.png", brand: "Williams-Sonoma", productType: "Home Essentials"),
                ProductItem(id: "col_10", title: "Handcrafted Bread Basket", price: 39.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/bread_basket_1779007588947.png", brand: "Williams-Sonoma", productType: "Tabletop")
            ]
        ),
        HeroItem(
            title: "Summer Kitchen",
            subtitle: "Elevate your culinary experience with our premium summer essentials.",
            imageName: "img153m.jpg",
            buttonText: "Shop Summer",
            products: [
                ProductItem(id: "sum_1", title: "Outdoor Stone Pizza Oven", price: 299.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/pizza_oven_1779007606970.png", brand: "Williams-Sonoma", productType: "Electrics"),
                ProductItem(id: "sum_2", title: "Williams Sonoma BBQ Tool Set (4-Piece)", price: 89.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/utensils_1779007398920.png", brand: "Williams-Sonoma", productType: "Tools"),
                ProductItem(id: "sum_3", title: "Staub Cast Iron Grill Pan", price: 149.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/fry_pan_1779007348244.png", brand: "Staub", productType: "Cookware"),
                ProductItem(id: "sum_4", title: "Artisan Woodfired Pizza Peel", price: 49.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/baking_sheet_1779007429395.png", brand: "Williams-Sonoma", productType: "Tools"),
                ProductItem(id: "sum_5", title: "Citrus Outdoor Goblets (Set of 6)", price: 45.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/wine_glasses_1779007476041.png", brand: "Williams-Sonoma", productType: "Tabletop"),
                ProductItem(id: "sum_6", title: "Acacia Wood Salad Bowl Set", price: 79.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/salad_plates_1779007557204.png", brand: "Williams-Sonoma", productType: "Tabletop"),
                ProductItem(id: "sum_7", title: "Stainless Steel Grilling Basket", price: 39.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/baking_sheet_1779007429395.png", brand: "Williams-Sonoma", productType: "Tools"),
                ProductItem(id: "sum_8", title: "Lodge Seasoned Cast Iron Plancha", price: 59.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/baking_sheet_1779007429395.png", brand: "Lodge", productType: "Cookware"),
                ProductItem(id: "sum_9", title: "Melamine Dinner Plates (Set of 4)", price: 34.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/salad_plates_1779007557204.png", brand: "Williams-Sonoma", productType: "Tabletop"),
                ProductItem(id: "sum_10", title: "Gourmet Wood Chip Smoker Box", price: 24.95, path: "file:///Users/rohannaik/.gemini/antigravity/brain/7bb55bfb-7636-487e-a083-bbe806baf00e/bread_basket_1779007588947.png", brand: "Williams-Sonoma", productType: "Tools")
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selection) {
                ForEach(0..<items.count, id: \.self) { index in
                    HeroSlideView(item: items[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 400) // Increased height for a more "heroic" feel
            
            // Custom Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<items.count, id: \.self) { index in
                    Circle()
                        .fill(selection == index ? Color.primary : Color.primary.opacity(0.2))
                        .frame(width: 8, height: 8)
                        .animation(.spring(), value: selection)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
    }
}

struct HeroSlideView: View {
    let item: HeroItem
    
    var body: some View {
        NavigationLink(destination: HeroDetailView(title: item.title, subtitle: item.subtitle, products: item.products)) {
            ZStack(alignment: .bottomLeading) {
                // Main Hero Image
                AsyncImage(url: URL(string: AppConstants.API.imageBasePath + item.imageName)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Color.gray.opacity(0.1)
                    case .empty:
                        Rectangle().fill(Color.gray.opacity(0.05))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                .clipped()
                
                // Sophisticated Gradient Merge
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGroupedBackground), // Merges into the background color
                        Color(.systemGroupedBackground).opacity(0.8),
                        Color(.systemGroupedBackground).opacity(0.4),
                        .clear
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.title)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(item.subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: 280, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(item.buttonText)
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.primary)
                    .foregroundColor(Color(.systemBackground))
                    .cornerRadius(2)
                    .padding(.top, 8)
                }
                .padding(24)
                .padding(.bottom, 20) // Extra space for the gradient merge
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
