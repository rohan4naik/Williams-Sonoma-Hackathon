//
//  SavedAddressesView.swift
//  WSHackathonApp
//

import SwiftUI

struct SavedAddressesView: View {
    @EnvironmentObject var profileRepo: UserProfileRepository
    @State private var showingAddSheet = false
    
    var body: some View {
        List {
            ForEach(profileRepo.savedAddresses) { address in
                Button(action: { profileRepo.selectAddress(id: address.id) }) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(address.label)
                                    .font(.headline)
                                if address.isSelected {
                                    Text("Selected")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.green)
                                        .clipShape(Capsule())
                                }
                            }
                            Text("\(address.firstName) \(address.lastName)")
                                .font(.subheadline)
                            Text("\(address.street), \(address.city), \(address.state) \(address.zipCode)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(address.phoneNumber)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if address.isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                indexSet.forEach { i in
                    profileRepo.deleteAddress(id: profileRepo.savedAddresses[i].id)
                }
            }
        }
        .navigationTitle("Saved Addresses")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") { showingAddSheet = true }
                    .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                AddNewAddressView(profileRepo: profileRepo)
            }
        }
    }
}

// MARK: - AddNewAddressView
struct AddNewAddressView: View {
    @ObservedObject var profileRepo: UserProfileRepository
    @Environment(\.dismiss) var dismiss
    
    @State private var label = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var phoneNumber = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AddressField(label: "Address Label (e.g. Home, Work)", text: $label)
                
                HStack(spacing: 16) {
                    AddressField(label: "First Name", text: $firstName)
                    AddressField(label: "Last Name", text: $lastName)
                }
                
                AddressField(label: "Street Address", text: $street)
                
                HStack(spacing: 16) {
                    AddressField(label: "City", text: $city)
                    AddressField(label: "State", text: $state, width: 80)
                    AddressField(label: "ZIP", text: $zipCode, width: 100)
                }
                
                AddressField(label: "Phone Number", text: $phoneNumber)
                
                Button(action: {
                    let newAddress = SavedAddress(
                        label: label,
                        firstName: firstName,
                        lastName: lastName,
                        street: street,
                        city: city,
                        state: state,
                        zipCode: zipCode,
                        phoneNumber: phoneNumber,
                        isSelected: true
                    )
                    profileRepo.addAddress(newAddress)
                    dismiss()
                }) {
                    Text("Save Address")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(label.isEmpty || street.isEmpty || city.isEmpty)
                .padding(.top, 20)
            }
            .padding(24)
        }
        .navigationTitle("Add New Address")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
