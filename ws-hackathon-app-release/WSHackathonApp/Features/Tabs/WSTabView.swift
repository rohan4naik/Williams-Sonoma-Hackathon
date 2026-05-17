//
//  WSTabView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

struct WSTabView: View {    
    @EnvironmentObject var viewModel: WSTabBarViewModel
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var collabManager: CollaborationManager
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set badge background color to black
        let badgeAppearance = UITabBarItemAppearance()
        badgeAppearance.normal.badgeBackgroundColor = .black
        badgeAppearance.selected.badgeBackgroundColor = .black
        
        appearance.stackedLayoutAppearance = badgeAppearance
        appearance.inlineLayoutAppearance = badgeAppearance
        appearance.compactInlineLayoutAppearance = badgeAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(viewModel.tabs, id: \.rawValue) { tab in
                view(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
                    .badge(tab == .cart ? (viewModel.cartItemCount > 0 ? viewModel.cartItemCount : 0) : 0)
            }
        }
        .onReceive(cartRepository.$items) { items in
            viewModel.cartItemCount = items.reduce(0) { $0 + $1.quantity }
        }
        .onAppear {
            viewModel.cartItemCount = cartRepository.items.reduce(0) { $0 + $1.quantity }
        }
    }
    
    @ViewBuilder
    private func view(for tab: TabItem) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .registry:
            RegistryView()
                .environmentObject(collabManager)
        case .cart:
            CartView()
        case .profile:
            ProfileView()
                .environmentObject(registryRepository)
        }
    }
}

#Preview {
    WSTabView()
}
