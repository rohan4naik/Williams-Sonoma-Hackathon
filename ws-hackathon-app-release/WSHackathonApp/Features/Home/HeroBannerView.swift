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
}

struct HeroBannerView: View {
    @State private var selection = 0
    
    let items = [
        HeroItem(
            title: "Exclusive Products",
            subtitle: "Discover our hand-selected assortment, available in a range of styles and colors.",
            imageName: "img23m.jpg",
            buttonText: "Explore Collection"
        ),
        HeroItem(
            title: "Collections",
            subtitle: "Curated sets designed to bring harmony and style to your home.",
            imageName: "shop_collections.png",
            buttonText: "View Collections"
        ),
        HeroItem(
            title: "Summer Kitchen",
            subtitle: "Elevate your culinary experience with our premium summer essentials.",
            imageName: "img153m.jpg",
            buttonText: "Shop Summer"
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
                
                Text(item.subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: 280, alignment: .leading)
                
                Button(action: {}) {
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
                }
                .padding(.top, 8)
            }
            .padding(24)
            .padding(.bottom, 20) // Extra space for the gradient merge
        }
    }
}
