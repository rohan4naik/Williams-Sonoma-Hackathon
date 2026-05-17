import Foundation
import Combine
import SwiftUI

struct MockUser: Identifiable, Hashable {
    let id: UUID
    let name: String
    let email: String
    let avatarInitials: String
    var registries: [Registry] = []
    
    static let alice = MockUser(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "Alice Johnson",
        email: "alice@example.com",
        avatarInitials: "AJ"
    )
    static let bob = MockUser(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "Bob Smith",
        email: "bob@example.com",
        avatarInitials: "BS"
    )
    static let carol = MockUser(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        name: "Carol White",
        email: "carol@example.com",
        avatarInitials: "CW"
    )
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

struct MockUserData {
    var cartItems: [CartItem] = []
    var savedAddresses: [SavedAddress] = []
    var pastOrders: [SimulatedOrder] = []
    var activeShipments: [SimulatedShipment] = []
    var phoneNumber: String = ""
}

struct MockProducts {
    static let product1 = ProductItem(
        id: "prod_001",
        title: "Williams Sonoma Signature Ceramic Dinner Plates",
        price: 120.00,
        path: "placeholder_dinner_plates.jpg",
        brand: "Williams Sonoma"
    )
    static let product2 = ProductItem(
        id: "prod_002",
        title: "Zwilling J.A. Henckels Gourmet 7-Piece Knife Block Set",
        price: 149.95,
        path: "placeholder_knife_set.jpg",
        brand: "Zwilling"
    )
    static let product3 = ProductItem(
        id: "prod_003",
        title: "All-Clad d5 Stainless Steel 10-Piece Cookware Set",
        price: 899.95,
        path: "placeholder_cookware_set.jpg",
        brand: "All-Clad"
    )
    static let product4 = ProductItem(
        id: "prod_004",
        title: "Le Creuset Enameled Cast Iron Dutch Oven, 5.5-Qt.",
        price: 419.95,
        path: "placeholder_dutch_oven.jpg",
        brand: "Le Creuset"
    )
}

@MainActor
final class MockUserManager: ObservableObject {
    static let shared = MockUserManager()
    
    @Published var currentUser: MockUser = .alice
    let allUsers: [MockUser] = [.alice, .bob, .carol]
    
    @Published var userDataStore: [UUID: MockUserData] = [:]
    
    private init() {
        seedData()
    }
    
    func dataForCurrentUser() -> MockUserData {
        userDataStore[currentUser.id] ?? MockUserData()
    }
    
    func addActiveShipment(_ shipment: SimulatedShipment) {
        if userDataStore[currentUser.id] == nil {
            userDataStore[currentUser.id] = MockUserData()
        }
        userDataStore[currentUser.id]?.activeShipments.insert(shipment, at: 0)
    }
    
    func performSwitch(
        to user: MockUser,
        cartRepo: CartRepository,
        registryRepo: RegistryRepository,
        collabManager: CollaborationManager
    ) {
        // 1. Save current user's cart
        userDataStore[currentUser.id]?.cartItems = cartRepo.items
        userDataStore[currentUser.id]?.savedAddresses = UserProfileRepository.shared.savedAddresses
        userDataStore[currentUser.id]?.phoneNumber = UserProfileRepository.shared.phoneNumber
        
        // 2. Save current user's registries explicitly before switching
        registryRepo.allUserRegistries[registryRepo.currentUserId] = registryRepo.registries
        
        // 3. Switch identity
        currentUser = user
        collabManager.switchUser(to: user)
        
        // 4. Restore new user's data
        registryRepo.switchUser(to: user.id)
        let data = userDataStore[user.id] ?? MockUserData()
        cartRepo.items = data.cartItems
        UserProfileRepository.shared.savedAddresses = data.savedAddresses
        UserProfileRepository.shared.phoneNumber = data.phoneNumber
    }
    
    private func seedData() {
        // 1. Alice Johnson
        let aliceAddress1 = SavedAddress(
            id: UUID(),
            label: "Home",
            firstName: "Alice",
            lastName: "Johnson",
            street: "742 Evergreen Terrace",
            city: "San Francisco",
            state: "CA",
            zipCode: "94102",
            phoneNumber: "+1 (415) 555-0101",
            isSelected: true
        )
        let aliceAddress2 = SavedAddress(
            id: UUID(),
            label: "Work",
            firstName: "Alice",
            lastName: "Johnson",
            street: "1 Infinite Loop",
            city: "Cupertino",
            state: "CA",
            zipCode: "95014",
            phoneNumber: "+1 (415) 555-0101",
            isSelected: false
        )
        
        let aliceOrders = [
            SimulatedOrder(
                id: "WS-97834",
                date: "May 2, 2026",
                status: "Delivered",
                items: [SimulatedOrderItem(product: MockProducts.product1, quantity: 1)],
                total: MockProducts.product1.price ?? 0.0
            ),
            SimulatedOrder(
                id: "WS-95482",
                date: "April 20, 2026",
                status: "Delivered",
                items: [
                    SimulatedOrderItem(product: MockProducts.product2, quantity: 1),
                    SimulatedOrderItem(product: MockProducts.product3, quantity: 2)
                ],
                total: (MockProducts.product2.price ?? 0.0) + (MockProducts.product3.price ?? 0.0) * 2
            ),
            SimulatedOrder(
                id: "WS-91283",
                date: "March 15, 2026",
                status: "Delivered",
                items: [SimulatedOrderItem(product: MockProducts.product4, quantity: 1)],
                total: MockProducts.product4.price ?? 0.0
            )
        ]
        
        let aliceActiveShipments = [
            SimulatedShipment(
                id: "10492",
                estimatedDelivery: "Tomorrow by 5:00 PM",
                carrier: "FedEx",
                trackingNumber: "#783948293849",
                statusText: "Out for Delivery",
                statusColor: .indigo,
                items: [SimulatedOrderItem(product: MockProducts.product1, quantity: 1)],
                steps: [
                    StatusStep(title: "Out for Delivery", time: "Today, 8:15 AM", description: "Your package is with the courier for local delivery.", isCompleted: true, isActive: true),
                    StatusStep(title: "Arrived at Local Facility", time: "Yesterday, 11:30 PM", description: "Package arrived at local distribution hub.", isCompleted: true, isActive: false),
                    StatusStep(title: "In Transit", time: "May 15, 4:00 PM", description: "Package is on its way from primary fulfillment center.", isCompleted: true, isActive: false),
                    StatusStep(title: "Order Placed & Confirmed", time: "May 14, 10:00 AM", description: "Payment verified and order sent to warehouse.", isCompleted: true, isActive: false)
                ]
            ),
            SimulatedShipment(
                id: "10521",
                estimatedDelivery: "Thursday, May 21",
                carrier: "UPS",
                trackingNumber: "#1Z99A9999999999999",
                statusText: "In Transit",
                statusColor: .orange,
                items: [SimulatedOrderItem(product: MockProducts.product2, quantity: 1)],
                steps: [
                    StatusStep(title: "Out for Delivery", time: "Estimated May 21", description: "Package will be assigned to a local courier on delivery day.", isCompleted: false, isActive: false),
                    StatusStep(title: "Arrived at Local Facility", time: "Pending", description: "Package will scan at local center upon arrival.", isCompleted: false, isActive: false),
                    StatusStep(title: "In Transit", time: "Today, 4:30 AM", description: "Package departed hub and is in transit to destination facility.", isCompleted: true, isActive: true),
                    StatusStep(title: "Order Placed & Confirmed", time: "May 16, 2:00 PM", description: "Payment verified and order processed successfully.", isCompleted: true, isActive: false)
                ]
            )
        ]
        
        userDataStore[MockUser.alice.id] = MockUserData(
            cartItems: [],
            savedAddresses: [aliceAddress1, aliceAddress2],
            pastOrders: aliceOrders,
            activeShipments: aliceActiveShipments,
            phoneNumber: "+1 (415) 555-0101"
        )
        
        // 2. Bob Smith
        let bobAddress = SavedAddress(
            id: UUID(),
            label: "Home",
            firstName: "Bob",
            lastName: "Smith",
            street: "221B Baker Street",
            city: "San Francisco",
            state: "CA",
            zipCode: "94110",
            phoneNumber: "+1 (415) 555-0202",
            isSelected: true
        )
        
        let bobOrders = [
            SimulatedOrder(
                id: "WS-88392",
                date: "May 10, 2026",
                status: "Delivered",
                items: [SimulatedOrderItem(product: MockProducts.product1, quantity: 1)],
                total: MockProducts.product1.price ?? 0.0
            )
        ]
        
        let bobActiveShipments = [
            SimulatedShipment(
                id: "10711",
                estimatedDelivery: "Friday, May 22",
                carrier: "FedEx",
                trackingNumber: "#783948291234",
                statusText: "Processing",
                statusColor: .indigo,
                items: [SimulatedOrderItem(product: MockProducts.product3, quantity: 1)],
                steps: [
                    StatusStep(title: "Order Placed & Confirmed", time: "Today, 9:00 AM", description: "Payment verified and order sent to warehouse.", isCompleted: true, isActive: true)
                ]
            )
        ]
        
        userDataStore[MockUser.bob.id] = MockUserData(
            cartItems: [],
            savedAddresses: [bobAddress],
            pastOrders: bobOrders,
            activeShipments: bobActiveShipments,
            phoneNumber: "+1 (415) 555-0202"
        )
        
        // 3. Carol White
        userDataStore[MockUser.carol.id] = MockUserData(
            cartItems: [],
            savedAddresses: [],
            pastOrders: [],
            activeShipments: [],
            phoneNumber: "+1 (415) 555-0303"
        )
    }
}
