//
//  CheckoutView.swift
//  WSHackathonApp
//
//  Created by Antigravity on 16/05/26.
//

import SwiftUI
import MapKit

struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    @EnvironmentObject var cartRepository: CartRepository
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            if viewModel.orderPlaced {
                OrderSuccessView()
            } else {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // MARK: - Shipping Address
                            CheckoutSection(title: "Shipping Address", icon: "shippingbox.fill") {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(viewModel.fullAddress)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                            .lineSpacing(4)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.showingAddressEditor = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.blue)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .sheet(isPresented: $viewModel.showingAddressEditor) {
                                ShippingDetailsForm(viewModel: viewModel)
                                    .presentationDetents([.large])
                                    .presentationDragIndicator(.visible)
                            }
                            
                            // MARK: - Delivery Method
                            CheckoutSection(title: "Delivery Method", icon: "truck.fill") {
                                VStack(spacing: 0) {
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            viewModel.showingDeliveryDropdown.toggle()
                                        }
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(viewModel.selectedDeliveryMethod.rawValue)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)
                                                Text(viewModel.selectedDeliveryMethod.price == 0 ? "FREE" : "$\(viewModel.selectedDeliveryMethod.price, specifier: "%.0f").00")
                                                    .font(.caption)
                                                    .foregroundColor(viewModel.selectedDeliveryMethod.price == 0 ? .green : .secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.secondary)
                                                .rotationEffect(.degrees(viewModel.showingDeliveryDropdown ? 180 : 0))
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(.systemGray4), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if viewModel.showingDeliveryDropdown {
                                        VStack(spacing: 0) {
                                            ForEach(CheckoutViewModel.DeliveryMethod.allCases.filter { $0 != viewModel.selectedDeliveryMethod }, id: \.self) { method in
                                                Button(action: {
                                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                        viewModel.selectedDeliveryMethod = method
                                                        viewModel.showingDeliveryDropdown = false
                                                    }
                                                }) {
                                                    HStack {
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(method.rawValue)
                                                                .font(.subheadline)
                                                                .foregroundColor(.primary)
                                                            Text(method.price == 0 ? "FREE" : "$\(method.price, specifier: "%.0f").00")
                                                                .font(.caption)
                                                                .foregroundColor(method.price == 0 ? .green : .secondary)
                                                        }
                                                        Spacer()
                                                    }
                                                    .padding()
                                                    .background(Color.clear)
                                                }
                                                .buttonStyle(.plain)
                                                
                                                if method != CheckoutViewModel.DeliveryMethod.allCases.filter({ $0 != viewModel.selectedDeliveryMethod }).last {
                                                    Divider()
                                                        .padding(.horizontal)
                                                }
                                            }
                                        }
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .padding(.top, 8)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                            }
                            
                            // MARK: - Promo Code
                            CheckoutSection(title: "Promo Code", icon: "tag.fill") {
                                HStack(spacing: 12) {
                                    TextField("Enter code (e.g. SAVE10)", text: $viewModel.promoCode)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(12)
                                        .autocapitalization(.allCharacters)
                                    
                                    Button(action: {
                                        viewModel.applyPromoCode()
                                    }) {
                                        Text("Apply")
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(Color.black)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                }
                                
                                if viewModel.isPromoApplied {
                                    Text("Promo code applied successfully!")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .padding(.top, 4)
                                }
                            }
                            
                            // MARK: - Order Summary
                            CheckoutSection(title: "Order Summary", icon: "list.bullet.rectangle.fill") {
                                VStack(alignment: .leading, spacing: 16) {
                                    // Item Breakdown
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.items) { item in
                                            CheckoutItemRow(item: item)
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    // Price Summary
                                    VStack(spacing: 12) {
                                        SummaryRow(label: "Subtotal", value: viewModel.subtotal)
                                        
                                        if viewModel.isPromoApplied {
                                            SummaryRow(label: "Discount", value: viewModel.discountAmount, isDiscount: true)
                                        }
                                        
                                        SummaryRow(label: "Shipping", value: viewModel.shippingFee, isFree: viewModel.shippingFee == 0)
                                        SummaryRow(label: "Tax (8.5%)", value: viewModel.tax)
                                        
                                        Divider()
                                            .padding(.vertical, 4)
                                        
                                        HStack {
                                            Text("Total")
                                                .font(.system(size: 18, weight: .bold))
                                            Spacer()
                                            Text("$\(viewModel.total, specifier: "%.2f")")
                                                .font(.system(size: 22, weight: .bold))
                                        }
                                    }
                                }
                            }
                            
                            // MARK: - Payment Method
                            CheckoutSection(title: "Payment Method", icon: "creditcard.fill") {
                                VStack(spacing: 16) {
                                    PaymentTypeButton(type: .applePay, isSelected: viewModel.paymentMethod == .applePay) {
                                        viewModel.paymentMethod = .applePay
                                    }
                                    PaymentTypeButton(type: .paypal, isSelected: viewModel.paymentMethod == .paypal) {
                                        viewModel.paymentMethod = .paypal
                                    }
                                }
                            }
                            
                            Spacer().frame(height: 100)
                        }
                        .padding()
                    }
                    
                    // MARK: - Place Order Button
                    VStack {
                        Button(action: {
                            let haptic = UIImpactFeedbackGenerator(style: .heavy)
                            haptic.impactOccurred()
                            viewModel.placeOrder()
                        }) {
                            HStack {
                                if viewModel.isProcessing {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 8)
                                }
                                Text(viewModel.isProcessing ? "Processing..." : "Place Order")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(viewModel.isProcessing ? Color.gray : Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .disabled(viewModel.isProcessing)
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                }
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.bind(repository: cartRepository)
        }
    }
}

// MARK: - Shipping Details Form

struct ShippingDetailsForm: View {
    @ObservedObject var viewModel: CheckoutViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 12) {
                        Image(systemName: "shippingbox.fill")
                            .foregroundColor(.secondary)
                        Text("Shipping Details")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // First & Last Name
                        HStack(spacing: 16) {
                            AddressField(label: "First Name", text: $viewModel.firstName)
                            AddressField(label: "Last Name", text: $viewModel.lastName)
                        }
                    }
                    
                    // MARK: - Map Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Location")
                            .font(.headline)
                        
                        ZStack {
                            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                                .frame(height: 180)
                                .cornerRadius(16)
                            
                            Image(systemName: "mappin")
                                .font(.title)
                                .foregroundColor(.red)
                                .offset(y: -15)
                        }
                        .overlay(
                            Button(action: {
                                updateAddressFromMap()
                            }) {
                                Text("Use Map Location")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(8)
                                    .background(Color.black.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(8),
                            alignment: .bottomTrailing
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Street Address
                        AddressField(label: "Street Address", text: $viewModel.streetAddress)
                        
                        // City, State, ZIP
                        HStack(spacing: 16) {
                            AddressField(label: "City", text: $viewModel.city)
                            AddressField(label: "State", text: $viewModel.state, width: 80)
                            AddressField(label: "ZIP", text: $viewModel.zipCode, width: 100)
                        }
                        
                        // Phone Number
                        AddressField(label: "Phone Number", text: $viewModel.phoneNumber)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Save Address")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.top, 20)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func updateAddressFromMap() {
        let location = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else { return }
            
            DispatchQueue.main.async {
                viewModel.streetAddress = [placemark.subThoroughfare, placemark.thoroughfare]
                    .compactMap { $0 }
                    .joined(separator: " ")
                viewModel.city = placemark.locality ?? ""
                viewModel.state = placemark.administrativeArea ?? ""
                viewModel.zipCode = placemark.postalCode ?? ""
            }
        }
    }
}

struct AddressField: View {
    let label: String
    @Binding var text: String
    var width: CGFloat? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("", text: $text)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .frame(width: width)
        }
    }
}

// MARK: - Subviews

struct CheckoutSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        }
    }
}

struct PaymentTypeButton: View {
    let type: CheckoutViewModel.PaymentMethodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                switch type {
                case .applePay:
                    Image(systemName: "applelogo")
                        .font(.title3)
                    Text(" Pay")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                case .paypal:
                    HStack(spacing: 0) {
                        Text("Pay")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .italic()
                            .foregroundColor(Color(red: 0/255, green: 48/255, blue: 135/255))
                        Text("Pal")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .italic()
                            .foregroundColor(Color(red: 0/255, green: 156/255, blue: 222/255))
                        Text(" Checkout")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? Color.black.opacity(0.1) : Color.clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        switch type {
        case .applePay:
            return .black
        case .paypal:
            return Color(red: 255/255, green: 196/255, blue: 57/255)
        }
    }
    
    private var foregroundColor: Color {
        switch type {
        case .applePay:
            return .white
        case .paypal:
            return .black
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: Double
    var isFree: Bool = false
    var isDiscount: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            if isFree {
                Text("FREE")
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            } else {
                Text("\(isDiscount ? "-" : "")$\(value, specifier: "%.2f")")
                    .foregroundColor(isDiscount ? .green : .primary)
            }
        }
        .font(.system(size: 15))
    }
}

struct OrderSuccessView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 12) {
                Text("Order Placed!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Thank you for your purchase. Your order #WS-94109 is being processed.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Continue Shopping")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
    }
}

struct CheckoutItemRow: View {
    let item: CartItem
    
    var body: some View {
        HStack(spacing: 12) {
            CustomAsyncImage(url: item.imageURL)
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack {
                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
            .environmentObject(CartRepository())
    }
}
