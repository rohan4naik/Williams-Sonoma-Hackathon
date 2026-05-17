//
//  MockUserManager.swift
//  WSHackathonApp
//

import Foundation
import Combine

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

struct MockUserData {
    var cartItems: [CartItem] = []
    var savedAddresses: [SavedAddress] = []
    var pastOrders: [SimulatedOrder] = []
    var phoneNumber: String = ""
}

struct MockProducts {
    static let product1 = ProductItem(
        id: "prod_001",
        title: "Williams Sonoma Signature Ceramic Dinner Plates",
        price: 120.00,
        path: "dinner_plates.jpg",
        brand: "Williams Sonoma"
    )
    static let product2 = ProductItem(
        id: "prod_002",
        title: "Zwilling J.A. Henckels Gourmet 7-Piece Knife Block Set",
        price: 149.95,
        path: "knife_set.jpg",
        brand: "Zwilling"
    )
    static let product3 = ProductItem(
        id: "prod_003",
        title: "All-Clad d5 Stainless Steel 10-Piece Cookware Set",
        price: 899.95,
        path: "cookware_set.jpg",
        brand: "All-Clad"
    )
    static let product4 = ProductItem(
        id: "prod_004",
        title: "Le Creuset Enameled Cast Iron Dutch Oven, 5.5-Qt.",
        price: 419.95,
        path: "dutch_oven.jpg",
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
        
        userDataStore[MockUser.alice.id] = MockUserData(
            cartItems: [],
            savedAddresses: [aliceAddress1, aliceAddress2],
            pastOrders: aliceOrders,
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
        
        userDataStore[MockUser.bob.id] = MockUserData(
            cartItems: [],
            savedAddresses: [bobAddress],
            pastOrders: bobOrders,
            phoneNumber: "+1 (415) 555-0202"
        )
        
        // 3. Carol White
        userDataStore[MockUser.carol.id] = MockUserData(
            cartItems: [],
            savedAddresses: [],
            pastOrders: [],
            phoneNumber: "+1 (415) 555-0303"
        )
    }
}
