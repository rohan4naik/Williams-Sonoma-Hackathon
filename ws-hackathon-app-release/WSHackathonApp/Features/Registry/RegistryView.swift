//
//  RegistryView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

enum RegistryRoute: Hashable {
    case create
    case success
}

struct RegistryView: View {
    
    @StateObject private var viewModel = RegistryViewModel()
    @State private var selectedInstruction: RegistryInstruction? = nil
    
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    var body: some View {
        NavigationStack(path: $tabBarVM.registryPath) {
            
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // MARK: - Content
                        VStack(spacing: 24) {
                            
                            if viewModel.hasRegistry {
                                
                                registryHeader
                                
                                if viewModel.hasItems {
                                    registryItemsList
                                } else {
                                    emptyItemsView
                                }
                                
                            } else {
                                emptyStateView
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle(AppStrings.Registry.title)
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - Navigation
            
            .navigationDestination(for: RegistryRoute.self) { route in
                switch route {
                case .create:
                    CreateRegistryView()
                    
                case .success:
                    RegistrySuccessView()
                }
            }
            .sheet(item: $selectedInstruction) { instruction in
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Spacer()
                        Button {
                            selectedInstruction = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .frame(width: 56, height: 56)
                        Image(systemName: instruction.iconName)
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    }
                    
                    Text(instruction.detailedTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(instruction.detailedDescription)
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding(24)
                .presentationDetents([.fraction(0.4), .medium])
            }
        }
        .onAppear {
            viewModel.bind(repository: registryRepo)
        }
    }
}

// MARK: - Components
private extension RegistryView {
    
    var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 24) {
            headerSection
            heroCard
            reasonsSection
            howItWorksSection
        }
        .padding(.bottom, 24)
    }
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.Registry.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(AppStrings.Registry.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                Text(AppStrings.Registry.searchRegistryPlaceholder)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
    
    var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.Registry.brandName)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .textCase(.uppercase)
            
            Text(AppStrings.Registry.createPerfectRegistry)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 40)
            
            Button {
                tabBarVM.registryPath.append(.create)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text(AppStrings.Registry.getStarted)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.black)
                .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                Color(.systemGray6)
                Image("Image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.5)
            }
        )
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
    
    var reasonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.Registry.whyRegisterWithUs)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.instructions) { item in
                    reasonCard(for: item)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    func reasonCard(for instruction: RegistryInstruction) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                Image(systemName: instruction.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.black)
            }
            
            Text(instruction.title)
                .font(.subheadline)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
            
            Spacer(minLength: 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .onTapGesture {
            selectedInstruction = instruction
        }
    }
    
    var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.Registry.howItWorks)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.steps.enumerated()), id: \.element.id) { index, step in
                    stepRow(for: step)
                    
                    if index < viewModel.steps.count - 1 {
                        Divider()
                            .padding(.leading, 64)
                    }
                }
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 16)
        }
    }
    
    func stepRow(for step: RegistryStep) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 32, height: 32)
                Text("\(step.number)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(step.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    var emptyItemsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "basket")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            Text(AppStrings.Registry.noItemsAdded)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 40)
    }
    
    var registryItemsList: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Items")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.items.count) items")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 12) {
                ForEach(viewModel.items) { item in
                    RegistryItemRow(
                        viewModel: RegistryItemRowViewModel(
                            item: item,
                            registryRepo: registryRepo,
                            cartRepo: cartRepo,
                            tabbarVM: tabBarVM
                        )
                    )
                }
            }
        }
    }
    
    var registryHeader: some View {
        VStack(spacing: 12) {
            
            VStack(spacing: 4) {
                Text(viewModel.displayTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(viewModel.displayDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                viewModel.deleteRegistry(using: registryRepo)
            }) {
                Text("Manage Registry Settings")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black, lineWidth: 1)
                    )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
    }
}

