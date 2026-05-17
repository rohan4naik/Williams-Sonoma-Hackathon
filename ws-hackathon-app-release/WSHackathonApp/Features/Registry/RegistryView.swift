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
    case detail(UUID)
}

struct RegistryView: View {
    
    @StateObject private var viewModel = RegistryViewModel()
    
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    @State private var selectedInstruction: RegistryInstruction?
    
    @EnvironmentObject var collabManager: CollaborationManager
    @State private var showingJoinSheet = false
    
    var body: some View {
        NavigationStack(path: $tabBarVM.registryPath) {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if viewModel.hasRegistries {
                            registryList
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle(AppStrings.Registry.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingJoinSheet = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.badge.plus")
                            Text("Join")
                                .font(.subheadline)
                        }
                        .foregroundColor(.black)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        tabBarVM.registryPath.append(.create)
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                    }
                }
            }
            .navigationDestination(for: RegistryRoute.self) { route in
                switch route {
                case .create:
                    CreateRegistryView()
                case .success:
                    RegistrySuccessView()
                case .detail(let id):
                    RegistryDetailView(registryId: id)
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
            .sheet(isPresented: $showingJoinSheet) {
                JoinRegistryView()
                    .environmentObject(registryRepo)
                    .environmentObject(collabManager)
            }
        }
        .onAppear {
            viewModel.bind(repository: registryRepo)
        }
    }
}

// MARK: - Components
private extension RegistryView {
    
    var registryList: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.allRegistries) { registry in
                Button(action: {
                    tabBarVM.registryPath.append(.detail(registry.id))
                }) {
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            // Circular Image
                            Group {
                                if let imageData = registry.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    ZStack {
                                        Color(.systemGray6)
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(registry.displayName)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                
                                Text(registry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(registry.event.title)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(registry.items.count) items")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                        }
                        
                        // Progress bar for purchased items
                        let totalItems = registry.items.reduce(0) { $0 + $1.quantity }
                        // For demo, if there are items but none purchased, randomly mock 1 or 2 as purchased
                        let actualPurchased = registry.items.reduce(0) { $0 + $1.purchasedQuantity }
                        let purchasedItems = (totalItems > 0 && actualPurchased == 0) ? min(totalItems, Int.random(in: 1...2)) : actualPurchased
                        
                        VStack(spacing: 4) {
                            HStack {
                                Text("\(purchasedItems) of \(totalItems) items funded")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color(.systemGray6)).frame(height: 6)
                                    let progress = totalItems > 0 ? min(CGFloat(purchasedItems) / CGFloat(totalItems), 1.0) : 0
                                    Capsule().fill(Color.black).frame(width: geo.size.width * progress, height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 32) {
            headerSection
            heroCard
            reasonsSection
            howItWorksSection
        }
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
            
            Button {
                tabBarVM.registryPath.append(.create)
            } label: {
                Text(AppStrings.Registry.create)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
            }
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
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
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
                    if index != viewModel.steps.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 16)
        }
    }
    
    func stepRow(for step: RegistryStep) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                Text("\(step.number)")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}
