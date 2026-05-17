//
//  CompleteTheCollectionCard.swift
//  WSHackathonApp
//

import SwiftUI

// MARK: - Bundle Item State

private struct BundleItemState: Identifiable {
    let id: String
    let product: ProductItem
    var isSelected: Bool = true
    var quantity: Int = 1
}

// MARK: - Main Card

struct CompleteTheCollectionCard: View {
    let products: [ProductItem]
    let onAddToCart: ([(ProductItem, Int)]) -> Void

    @State private var isExpanded: Bool = false
    @State private var bundleItems: [BundleItemState] = []

    private let haptic = UIImpactFeedbackGenerator(style: .light)
    private let displayLimit = 3

    private var displayedItems: [BundleItemState] {
        Array(bundleItems.prefix(displayLimit))
    }

    private var selectedItems: [BundleItemState] {
        bundleItems.filter { $0.isSelected }
    }

    private var bundleTotal: Double {
        selectedItems.reduce(0) { $0 + (($1.product.price ?? 0) * Double($1.quantity)) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Product Image Row (Hero)
            productImageRow

            // MARK: - Bottom Bar (always visible)
            bottomBar

            // MARK: - Expanded Detail
            if isExpanded {
                expandedContent
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 6)
        .onAppear {
            bundleItems = products.map { BundleItemState(id: $0.id, product: $0) }
        }
    }

    // MARK: - Product Image Row

    private var productImageRow: some View {
        HStack(spacing: 8) {
            ForEach(Array(displayedItems.enumerated()), id: \.offset) { index, item in
                productThumbnail(product: item.product, isSelected: item.isSelected)

                if index < displayedItems.count - 1 || bundleItems.count > displayLimit {
                    Text("+")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                }
            }

            // +N more pill
            if bundleItems.count > displayLimit {
                Text("+\(bundleItems.count - displayLimit)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 56, height: 60)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func productThumbnail(product: ProductItem, isSelected: Bool) -> some View {
        VStack(spacing: 6) {
            CustomAsyncImage(url: product.imageURL)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .opacity(isSelected ? 1 : 0.35)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        Button(action: {
            haptic.impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Complete the Collection")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(String(format: "$%.2f total", bundleTotal))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6).opacity(0.6))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(spacing: 0) {
            Divider()

            VStack(spacing: 0) {
                ForEach(bundleItems.indices, id: \.self) { index in
                    BundleItemRow(item: $bundleItems[index])

                    if index < bundleItems.count - 1 {
                        Divider()
                            .padding(.leading, 72)
                    }
                }
            }

            Divider()

            // Footer: subtotal + CTA
            VStack(spacing: 12) {
                HStack {
                    Text("Subtotal")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "$%.2f", bundleTotal))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                }

                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    let selection = selectedItems.map { ($0.product, $0.quantity) }
                    onAddToCart(selection)
                }) {
                    Text(selectedItems.isEmpty
                         ? "Select items to add"
                         : "Add \(selectedItems.count) item\(selectedItems.count > 1 ? "s" : "") to Cart")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedItems.isEmpty ? .secondary : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(selectedItems.isEmpty ? Color(.systemGray5) : Color.black)
                        .clipShape(Capsule())
                }
                .disabled(selectedItems.isEmpty)
            }
            .padding(16)
        }
    }
}

// MARK: - Bundle Item Row

private struct BundleItemRow: View {
    @Binding var item: BundleItemState
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        HStack(spacing: 12) {
            // Rounded checkbox
            Button(action: {
                haptic.impactOccurred()
                withAnimation(.easeInOut(duration: 0.15)) {
                    item.isSelected.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(item.isSelected ? Color.primary : Color(.systemGray4), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if item.isSelected {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.primary)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            // Product image
            CustomAsyncImage(url: item.product.imageURL)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .opacity(item.isSelected ? 1 : 0.35)

            // Title + Price
            VStack(alignment: .leading, spacing: 3) {
                Text(item.product.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .opacity(item.isSelected ? 1 : 0.4)

                if let price = item.product.price {
                    Text(String(format: "$%.2f", price))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .opacity(item.isSelected ? 1 : 0.4)
                }
            }

            Spacer()

            // Compact stepper (only when selected)
            if item.isSelected {
                HStack(spacing: 10) {
                    Button(action: {
                        haptic.impactOccurred()
                        if item.quantity > 1 { item.quantity -= 1 }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Text("\(item.quantity)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .frame(minWidth: 14)

                    Button(action: {
                        haptic.impactOccurred()
                        item.quantity += 1
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
