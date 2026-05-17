//
//  UserProfileRepository.swift
//  WSHackathonApp
//

import Foundation
import Combine

struct UserProfile: Codable {
    let id: String
    let name: String
    let email: String
}

struct SavedAddress: Identifiable, Codable {
    var id: UUID = UUID()
    var label: String        // "Home", "Work", etc.
    var firstName: String
    var lastName: String
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var phoneNumber: String
    var isSelected: Bool
}

@MainActor
final class UserProfileRepository: ObservableObject {
    static let shared = UserProfileRepository()
    
    @Published var profile: UserProfile? = nil
    @Published var phoneNumber: String = "+1 (415) 555-0192"
    @Published var isLoading: Bool = false
    
    @Published var savedAddresses: [SavedAddress] = [
        SavedAddress(
            label: "Home",
            firstName: "Demo", lastName: "User",
            street: "742 Evergreen Terrace",
            city: "San Francisco", state: "CA",
            zipCode: "94102",
            phoneNumber: "+1 (415) 555-0192",
            isSelected: true
        ),
        SavedAddress(
            label: "Work",
            firstName: "Demo", lastName: "User",
            street: "1 Infinite Loop",
            city: "Cupertino", state: "CA",
            zipCode: "95014",
            phoneNumber: "+1 (408) 555-0123",
            isSelected: false
        )
    ]
    
    private init() {}
    
    func fetchProfile() async {
        isLoading = true
        do {
            let fetched: UserProfile = try await APIClient.shared.request(
                Endpoint(path: "/profile", method: .get)
            )
            self.profile = fetched
        } catch {
            self.profile = UserProfile(
                id: "user_001",
                name: "Demo User",
                email: "demo@hackathon.com"
            )
        }
        isLoading = false
    }
    
    func selectAddress(id: UUID) {
        for i in savedAddresses.indices {
            savedAddresses[i].isSelected = savedAddresses[i].id == id
        }
    }
    
    func addAddress(_ address: SavedAddress) {
        var all = savedAddresses
        for i in all.indices { all[i].isSelected = false }
        var newAddr = address
        newAddr.isSelected = true
        all.append(newAddr)
        savedAddresses = all
    }
    
    func deleteAddress(id: UUID) {
        savedAddresses.removeAll { $0.id == id }
        if !savedAddresses.isEmpty,
           !savedAddresses.contains(where: { $0.isSelected }) {
            savedAddresses[0].isSelected = true
        }
    }
}
