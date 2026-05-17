//
//  ProfileSheetView.swift
//  WSHackathonApp
//

import SwiftUI

struct ProfileSheetView: View {
    @EnvironmentObject var registryRepository: RegistryRepository
    @Binding var isPresented: Bool
    
    @State private var email = "kunalkhude29@gmail.com"
    @State private var name = "Kunal Khude"
    
    var body: some View {
        NavigationStack {
            List {
                // ACCOUNT INFO
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text("KK")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(name)
                                .font(.headline)
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // ORDERS SECTION (TRACKING & PAST ORDERS)
                Section(header: Text("My Orders")) {
                    NavigationLink(destination: ProfileTrackShipmentsListView()) {
                        HStack {
                            Image(systemName: "box.truck")
                                .foregroundColor(.indigo)
                                .frame(width: 24)
                            Text("Track Active Orders")
                            Spacer()
                            let activeCount = ProductRepository.shared.products.count >= 6 ? 2 : 1
                            Text("\(activeCount) active")
                                .font(.caption.bold())
                                .foregroundColor(.indigo)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.indigo.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    
                    NavigationLink(destination: ProfilePastOrdersView()) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("Past Orders")
                            Spacer()
                            let ordersCount = ProductRepository.shared.products.count >= 4 ? 3 : 0
                            Text("\(ordersCount) orders")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // REGISTRIES
                Section(header: Text("Gift Registries")) {
                    NavigationLink(destination: ProfileRegistryListView()) {
                        HStack {
                            Image(systemName: "gift")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("My Registries")
                            Spacer()
                            Text("\(registryRepository.registries.count) active")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // ACCOUNT SETTINGS
                Section(header: Text("Account Settings")) {
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        Text("Payment Methods")
                        Spacer()
                        Text("Apple Pay")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        Text("Saved Addresses")
                        Spacer()
                        Text("1 address")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Notifications")
                        Spacer()
                        Text("Enabled")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Shipment Models
struct SimulatedShipment: Identifiable {
    let id: String
    let estimatedDelivery: String
    let carrier: String
    let trackingNumber: String
    let statusText: String
    let statusColor: Color
    let items: [SimulatedOrderItem]
    let steps: [StatusStep]
}

struct StatusStep: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let description: String
    let isCompleted: Bool
    let isActive: Bool
}

struct SimulatedOrder: Identifiable {
    let id: String
    let date: String
    let status: String
    let items: [SimulatedOrderItem]
    let total: Double
}

struct SimulatedOrderItem: Identifiable {
    let id = UUID()
    let product: ProductItem
    let quantity: Int
}

// MARK: - Track Shipments List View
struct ProfileTrackShipmentsListView: View {
    private var activeShipments: [SimulatedShipment] {
        let allProducts = ProductRepository.shared.products
        guard allProducts.count >= 2 else { return [] }
        
        let firstProduct = allProducts[0]
        let secondProduct = allProducts.count >= 6 ? allProducts[5] : allProducts[1]
        
        return [
            SimulatedShipment(
                id: "WS-10492",
                estimatedDelivery: "Tomorrow by 5:00 PM",
                carrier: "FedEx",
                trackingNumber: "#783948293849",
                statusText: "Out for Delivery",
                statusColor: .indigo,
                items: [SimulatedOrderItem(product: firstProduct, quantity: 1)],
                steps: [
                    StatusStep(title: "Out for Delivery", time: "Today, 8:15 AM", description: "Your package is with the courier for local delivery.", isCompleted: true, isActive: true),
                    StatusStep(title: "Arrived at Local Facility", time: "Yesterday, 11:30 PM", description: "Package arrived at local distribution hub.", isCompleted: true, isActive: false),
                    StatusStep(title: "In Transit", time: "May 15, 4:00 PM", description: "Package is on its way from primary fulfillment center.", isCompleted: true, isActive: false),
                    StatusStep(title: "Order Placed & Confirmed", time: "May 14, 10:00 AM", description: "Payment verified and order sent to warehouse.", isCompleted: true, isActive: false)
                ]
            ),
            SimulatedShipment(
                id: "WS-10521",
                estimatedDelivery: "Thursday, May 21",
                carrier: "UPS",
                trackingNumber: "#1Z99A9999999999999",
                statusText: "In Transit",
                statusColor: .orange,
                items: [SimulatedOrderItem(product: secondProduct, quantity: 1)],
                steps: [
                    StatusStep(title: "Out for Delivery", time: "Estimated May 21", description: "Package will be assigned to a local courier on delivery day.", isCompleted: false, isActive: false),
                    StatusStep(title: "Arrived at Local Facility", time: "Pending", description: "Package will scan at local center upon arrival.", isCompleted: false, isActive: false),
                    StatusStep(title: "In Transit", time: "Today, 4:30 AM", description: "Package departed hub and is in transit to destination facility.", isCompleted: true, isActive: true),
                    StatusStep(title: "Order Placed & Confirmed", time: "May 16, 2:00 PM", description: "Payment verified and order processed successfully.", isCompleted: true, isActive: false)
                ]
            )
        ]
    }
    
    var body: some View {
        List {
            if activeShipments.isEmpty {
                ProfileEmptyStateView(
                    title: "No Active Shipments",
                    systemImage: "box.truck",
                    description: "You don't have any active shipments right now."
                )
            } else {
                ForEach(activeShipments) { shipment in
                    NavigationLink(destination: ProfileTrackOrderDetailView(shipment: shipment)) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Order #\(shipment.id)")
                                    .font(.headline)
                                Spacer()
                                Text(shipment.statusText)
                                    .font(.caption.bold())
                                    .foregroundColor(shipment.statusColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(shipment.statusColor.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            
                            HStack(spacing: 12) {
                                if let firstItem = shipment.items.first {
                                    CustomAsyncImage(url: firstItem.product.imageURL)
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(firstItem.product.title)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                        
                                        Text("Est. Delivery: \(shipment.estimatedDelivery)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Active Shipments")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Track Order Detail View
struct ProfileTrackOrderDetailView: View {
    let shipment: SimulatedShipment
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Order info
                VStack(spacing: 12) {
                    Text("ESTIMATED DELIVERY")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                        .tracking(1.5)
                    
                    Text(shipment.estimatedDelivery)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("Carrier: \(shipment.carrier) · Tracking: \(shipment.trackingNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Stepper status timeline
                VStack(alignment: .leading, spacing: 0) {
                    Text("Delivery Status")
                        .font(.headline)
                        .padding(.bottom, 16)
                    
                    ForEach(Array(shipment.steps.enumerated()), id: \.element.id) { index, step in
                        StatusRow(
                            title: step.title,
                            time: step.time,
                            description: step.description,
                            isCompleted: step.isCompleted,
                            isActive: step.isActive,
                            isLast: index == shipment.steps.count - 1
                        )
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                
                // Item in this order
                if let product = shipment.items.first?.product {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Items in this shipment")
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        HStack(spacing: 12) {
                            CustomAsyncImage(url: product.imageURL)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(.subheadline.bold())
                                    .lineLimit(2)
                                Text("Quantity: 1 · Price: \(product.price?.formatted(.currency(code: "USD")) ?? "")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .navigationTitle("Shipment Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Status Row (Timeline component)
struct StatusRow: View {
    let title: String
    let time: String
    let description: String
    let isCompleted: Bool
    let isActive: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon / Line Column
            VStack(spacing: 0) {
                if isActive {
                    Circle()
                        .fill(Color.indigo)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.indigo.opacity(0.3), lineWidth: 4)
                                .scaleEffect(1.2)
                        )
                } else if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 14, height: 14)
                        .background(Color.white)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? (isActive ? Color.gray.opacity(0.3) : Color.green) : Color.gray.opacity(0.2))
                        .frame(width: 2, height: 60)
                }
            }
            .frame(width: 24)
            
            // Text Column
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: isActive ? .bold : .semibold))
                    .foregroundColor(isActive ? .indigo : (isCompleted ? .primary : .secondary))
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.8))
                    .padding(.top, 2)
            }
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Past Orders View
struct ProfilePastOrdersView: View {
    private var simulatedOrders: [SimulatedOrder] {
        let allProducts = ProductRepository.shared.products
        guard allProducts.count >= 4 else { return [] }
        
        return [
            SimulatedOrder(
                id: "WS-97834",
                date: "May 2, 2026",
                status: "Delivered",
                items: [SimulatedOrderItem(product: allProducts[0], quantity: 1)],
                total: allProducts[0].price ?? 120.00
            ),
            SimulatedOrder(
                id: "WS-95482",
                date: "April 20, 2026",
                status: "Delivered",
                items: [
                    SimulatedOrderItem(product: allProducts[1], quantity: 1),
                    SimulatedOrderItem(product: allProducts[2], quantity: 2)
                ],
                total: (allProducts[1].price ?? 45.00) + (allProducts[2].price ?? 80.00) * 2
            ),
            SimulatedOrder(
                id: "WS-91283",
                date: "March 15, 2026",
                status: "Delivered",
                items: [SimulatedOrderItem(product: allProducts[3], quantity: 1)],
                total: allProducts[3].price ?? 299.99
            )
        ]
    }
    
    var body: some View {
        List {
            if simulatedOrders.isEmpty {
                ProfileEmptyStateView(
                    title: "No Order History",
                    systemImage: "clock.arrow.circlepath",
                    description: "Your past orders will appear here once you make a purchase."
                )
            } else {
                ForEach(simulatedOrders) { order in
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Order #\(order.id)")
                                    .font(.headline)
                                Spacer()
                                Text(order.status)
                                    .font(.caption.bold())
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            
                            Divider()
                            
                            ForEach(order.items) { item in
                                HStack(spacing: 12) {
                                    CustomAsyncImage(url: item.product.imageURL)
                                        .frame(width: 45, height: 45)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.product.title)
                                            .font(.caption)
                                            .lineLimit(1)
                                        Text("Qty: \(item.quantity)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(item.product.price?.formatted(.currency(code: "USD")) ?? "")
                                        .font(.caption.bold())
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Date: \(order.date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Total: ")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(order.total.formatted(.currency(code: "USD")))
                                    .font(.subheadline.bold())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Past Orders")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Registry List View
struct ProfileRegistryListView: View {
    @EnvironmentObject var registryRepository: RegistryRepository
    
    var body: some View {
        List {
            if registryRepository.registries.isEmpty {
                ProfileEmptyStateView(
                    title: "No Registries",
                    systemImage: "gift",
                    description: "Create a registry to share with friends and family."
                )
            } else {
                ForEach(registryRepository.registries) { registry in
                    NavigationLink(destination: ProfileRegistryDetailView(registry: registry)) {
                        HStack(spacing: 12) {
                            ZStack {
                                Color(.systemGray6)
                                Image(systemName: registry.event.iconName)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(registry.displayName)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Text("\(registry.items.count) items · \(registry.date.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("My Registries")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Registry Detail View
struct ProfileRegistryDetailView: View {
    let registry: Registry
    
    var body: some View {
        List {
            Section(header: Text("Registry Details")) {
                LabeledContent("Event", value: registry.event.title)
                LabeledContent("Date", value: registry.date.formatted(date: .abbreviated, time: .omitted))
                LabeledContent("Registrant", value: "\(registry.firstName) \(registry.lastName)")
            }
            
            Section(header: Text("Registry Items")) {
                if registry.items.isEmpty {
                    Text("No items added to this registry yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(registry.items) { item in
                        HStack(spacing: 12) {
                            CustomAsyncImage(url: item.imageURL)
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.caption)
                                    .lineLimit(1)
                                Text("Quantity: \(item.quantity)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(registry.event.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable Empty State View
struct ProfileEmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }
}
