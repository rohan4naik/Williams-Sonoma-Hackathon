//
//  ProductCardView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import Foundation
import SwiftUI

// MARK: - Sparkle Particle Model
struct SparkleParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let distance: CGFloat
    let size: CGFloat
    let icon: String
}

// MARK: - Product Card View
struct ProductCardView: View {
    let product: ProductItem
    let quantity: Int
    let registryQuantity: Int
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onAddToRegistry: () -> Void
    let onRemoveFromRegistry: () -> Void
    
    @State private var cartBounce: CGFloat = 1.0
    @State private var cartShake: CGFloat = 0
    @State private var isAnimating: Bool = false
    @State private var particles: [SparkleParticle] = []
    @State private var particleProgress: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Image Section
            GeometryReader { geo in
                AsyncImage(url: product.imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.width)
                            .clipped()
                    } else if phase.error != nil {
                        ZStack {
                            Color(.systemGray6)
                            Image(systemName: "photo")
                                .foregroundColor(.gray.opacity(0.4))
                                .font(.system(size: 30))
                        }
                    } else {
                        ZStack {
                            Color(.systemGray6)
                            ProgressView()
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.width)
            }
            .aspectRatio(1, contentMode: .fit)
            
            // MARK: - Details Section
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(height: 36, alignment: .topLeading)
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("PRICE")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.secondary.opacity(0.7))
                        
                        Text(product.price?.formatted(.currency(code: "USD")) ?? "")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        // MARK: - Sparkle Particles
                        ForEach(particles) { particle in
                            Image(systemName: particle.icon)
                                .font(.system(size: particle.size, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .offset(
                                    x: isAnimating ? cos(particle.angle) * particle.distance : 0,
                                    y: isAnimating ? sin(particle.angle) * particle.distance : 0
                                )
                                .scaleEffect(isAnimating ? 1.0 : 0.2)
                                .opacity(isAnimating ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 0.55),
                                    value: isAnimating
                                )
                        }
                        
                        // MARK: - Cart Button
                        Button(action: {
                            triggerAddToCartAnimation()
                            onAdd()
                        }) {
                            Image(systemName: "cart")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.black)
                                .clipShape(Circle())
                        }
                        .scaleEffect(cartBounce)
                        .offset(x: cartShake)
                    }
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Animation Logic
    private func triggerAddToCartAnimation() {
        // 1. Haptic
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            let notif = UINotificationFeedbackGenerator()
            notif.notificationOccurred(.success)
        }
        
        // 2. Bounce
        withAnimation(.spring(response: 0.25, dampingFraction: 0.35)) {
            cartBounce = 1.4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                cartBounce = 1.0
            }
        }
        
        // 3. Shake
        withAnimation(.easeInOut(duration: 0.07).repeatCount(4, autoreverses: true)) {
            cartShake = 5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            cartShake = 0
        }
        
        // 4. Generate particles and burst them outward
        let icons = ["sparkle", "star.fill", "sparkle", "star.fill", "sparkle", "star.fill", "sparkle", "star.fill"]
        let count = 8
        particles = (0..<count).map { i in
            let angle = (Double(i) / Double(count)) * 2 * .pi
            return SparkleParticle(
                angle: angle,
                distance: CGFloat.random(in: 26...42),
                size: CGFloat.random(in: 7...11),
                icon: icons[i % icons.count]
            )
        }
        
        isAnimating = false
        // Trigger outward flight on next frame
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.easeOut(duration: 0.55)) {
                isAnimating = true
            }
            // Clean up after animation finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                particles = []
                isAnimating = false
            }
        }
    }
}
