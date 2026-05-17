//
//  ProductDetailView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 16/05/26.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ProductItem
    var relatedProducts: [ProductItem] = []
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    
    // For UI demonstration
    @State private var selectedColor: Int = 0
    @State private var quantity: Int = 1
    @State private var isAddedToCart: Bool = false
    @State private var isAddedToRegistry: Bool = false
    @State private var showNoRegistryAlert: Bool = false
    private let colors: [Color] = [.white, .black, Color(.systemGray4)]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Product Image
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: product.imageURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else if phase.error != nil {
                            ZStack {
                                Color(.systemGray6)
                                Image(systemName: "photo")
                                    .foregroundColor(.gray.opacity(0.4))
                                    .font(.system(size: 40))
                            }
                        } else {
                            ZStack {
                                Color(.systemGray6)
                                ProgressView()
                            }
                        }
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedCorner(radius: 50, corners: [.bottomLeft, .bottomRight]))
                    
                    // Floating Price Tag
                    Text(product.price?.formatted(.currency(code: "USD")) ?? "")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.35, green: 0.45, blue: 0.42)) // Subtle dark teal
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .offset(x: -24, y: 24)
                }
                .padding(.bottom, 24) // Extra space so the overlapping tag doesn't cover the title below
                
                // MARK: - Details
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.title)
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.primary)
                    }
                    
                    // Rating
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < 4 ? "star.fill" : "star.leadinghalf.filled")
                                .foregroundColor(.orange)
                                .font(.system(size: 14))
                        }
                        Text("(128 reviews)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color Options")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            ForEach(0..<colors.count, id: \.self) { index in
                                let isSelected = selectedColor == index
                                let ringColor: Color = isSelected ? .primary : .clear
                                let borderColor = Color(UIColor.systemGray4)
                                
                                Circle()
                                    .fill(colors[index])
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(ringColor, lineWidth: 2)
                                            .padding(-4)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(borderColor, lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedColor = index
                                        }
                                    }
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                        
                    // Quantity Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quantity")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                if quantity > 1 {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    quantity -= 1
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                                    .foregroundColor(quantity > 1 ? .primary : .gray.opacity(0.4))
                            }
                            .disabled(quantity <= 1)
                            
                            Text("\(quantity)")
                                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                                .frame(minWidth: 30, alignment: .center)
                            
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                quantity += 1
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Expandable Details
                    VStack(spacing: 0) {
                        Divider()
                            .padding(.top, 8)
                            
                        ExpandableSection(
                            title: "Description",
                            content: product.computedDescription,
                            initiallyExpanded: true
                        )
                        
                        ExpandableSection(
                            title: "Dimensions and Info",
                            content: "Overall dimensions: 12\" W x 10\" D x 4\" H.\nWeight: 2.5 lbs.\nMade from premium \(product.material ?? "materials") ensuring lasting durability and performance in your home."
                        )
                        
                        ExpandableSection(
                            title: "Use and Care",
                            content: "Hand wash recommended. Use a soft cloth with mild detergent. Avoid harsh abrasives or prolonged soaking to preserve the pristine finish."
                        )
                        
                        ExpandableSection(
                            title: "Shipping + Returns",
                            content: "Standard shipping typically arrives within 3-5 business days. Eligible for free returns within 30 days with original receipt or gift receipt."
                        )
                        
                        // Reviews Section
                        VStack(alignment: .leading, spacing: 16) {

                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                    Text("Write a Review")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Mock review
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Sarah M.")
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text("2 days ago")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                HStack(spacing: 2) {
                                    ForEach(0..<5) { _ in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 12))
                                    }
                                }
                                Text("Absolutely love this piece. The quality is exactly what you'd expect from Williams-Sonoma. It looks perfect in my home!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 16)
                    }
                    
                    if !relatedProducts.isEmpty {
                        Divider()
                            .padding(.vertical, 8)
                        
                        // You May Also Like Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("You may also like")
                                .font(.title3.bold())
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(relatedProducts) { relatedProduct in
                                        VStack(alignment: .leading, spacing: 8) {
                                            NavigationLink(destination: ProductDetailView(product: relatedProduct, relatedProducts: relatedProducts.shuffled())) {
                                                VStack(alignment: .leading, spacing: 8) {
                                                    AsyncImage(url: relatedProduct.imageURL) { phase in
                                                        if let image = phase.image {
                                                            image
                                                                .resizable()
                                                                .scaledToFill()
                                                        } else {
                                                            Color(.systemGray6)
                                                        }
                                                    }
                                                    .frame(width: 140, height: 140)
                                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                                    
                                                    Text(relatedProduct.title)
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.primary)
                                                        .lineLimit(2)
                                                        .frame(height: 36, alignment: .topLeading)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            HStack {
                                                Text(relatedProduct.price?.formatted(.currency(code: "USD")) ?? "")
                                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                                    .foregroundColor(.secondary)
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    cartRepository.add(product: relatedProduct)
                                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                                    generator.impactOccurred()
                                                }) {
                                                    Image(systemName: "plus")
                                                        .font(.system(size: 18, weight: .medium))
                                                        .foregroundColor(.primary)
                                                }
                                            }
                                        }
                                        .frame(width: 140)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // Extra spacing at bottom so content isn't hidden under the safeAreaInset
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    if cartRepository.isSaved(productId: product.id) {
                        cartRepository.removeFromSaved(productId: product.id)
                    } else {
                        cartRepository.saveForLater(product: product)
                    }
                }) {
                    Image(systemName: cartRepository.isSaved(productId: product.id) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                }
            }
        }
        // Native bottom bar for 'Add to Cart' & Registry
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if let registry = registryRepository.activeRegistry {
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundColor(.gray)
                        Text("Active Registry: \(registry.displayName)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
                
                HStack(spacing: 16) {
                    Button(action: {
                        let generator = UINotificationFeedbackGenerator()
                        
                        if let activeId = registryRepository.activeRegistryId {
                            generator.notificationOccurred(.success)
                            
                            // Match pattern to predefined registry category
                            let matchedCategory = RegistryCategory.matchingCategory(for: product.pattern)
                            let registry = registryRepository.registries.first { $0.id == activeId }
                            let categoryId = registry?.categories.first { $0.name == matchedCategory?.name }?.id
                            
                            let item = RegistryItem(
                                id: product.id,
                                title: product.title,
                                price: product.price ?? 0.0,
                                imageUrl: product.path,
                                quantity: quantity,
                                categoryId: categoryId
                            )
                            registryRepository.addProduct(item, to: activeId)
                            
                            withAnimation(.spring()) {
                                isAddedToRegistry = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.spring()) {
                                    isAddedToRegistry = false
                                }
                            }
                        } else {
                            generator.notificationOccurred(.error)
                            showNoRegistryAlert = true
                        }
                    }) {
                        Image(systemName: isAddedToRegistry ? "checkmark" : "gift")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(isAddedToRegistry ? .white : .primary)
                            .frame(width: 50, height: 50)
                            .background(isAddedToRegistry ? Color(red: 0.2, green: 0.6, blue: 0.3) : Color(.systemGray6))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isAddedToRegistry)
                    
                    Button(action: {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        cartRepository.add(product: product, quantity: quantity)
                        
                        withAnimation(.spring()) {
                            isAddedToCart = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.spring()) {
                                isAddedToCart = false
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if isAddedToCart {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isAddedToCart ? "Added to Cart" : "Add to Cart")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isAddedToCart ? Color(red: 0.2, green: 0.6, blue: 0.3) : Color.black)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isAddedToCart)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
        }
        .alert("No Active Registry", isPresented: $showNoRegistryAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please create a registry first to add items to it.")
        }
    }
}

// Helper for specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Expandable Section Component
struct ExpandableSection: View {
    let title: String
    let content: String
    @State private var isExpanded: Bool
    
    init(title: String, content: String, initiallyExpanded: Bool = false) {
        self.title = title
        self.content = content
        self._isExpanded = State(initialValue: initiallyExpanded)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.vertical, 16)
                .contentShape(Rectangle()) // Makes the whole row tappable
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .padding(.bottom, 16)
            }
            
            Divider()
        }
    }
}
