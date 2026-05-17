//
//  ProfileView.swift
//  WSHackathonApp
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var profileRepo = UserProfileRepository.shared
    @EnvironmentObject var registryRepository: RegistryRepository
    
    var body: some View {
        NavigationStack {
            ProfileContentView()
                .environmentObject(registryRepository)
                .environmentObject(profileRepo)
                .navigationTitle("Account")
                .navigationBarTitleDisplayMode(.inline)
                .task { await profileRepo.fetchProfile() }
        }
    }
}
