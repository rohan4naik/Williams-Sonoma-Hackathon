//
//  RegistryDetailView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 16/05/26.
//

import SwiftUI

struct RegistryDetailView: View {
    
    let registryId: UUID
    
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false
    @State private var searchText = ""
    
    // Categorization UI States
    @State private var targetedCategoryId: UUID? = nil
    @State private var isUncategorizedTargeted = false
    @State private var showingAddCategorySheet = false
    @State private var tappedPredefinedCategoryIds: Set<UUID> = []
    @State private var collapsedCategoryIds: Set<UUID> = []
    @State private var isUncategorizedCollapsed = false
    
    // Collaboration UI States
    @EnvironmentObject var collabManager: CollaborationManager
    @State private var showingShareSheet = false
    @State private var showingJoinSheet = false
    @State private var shareToken = ""
    @State private var showingContributionFor: RegistryItem? = nil
    @State private var showingCollabRequests = false
    @State private var copiedToClipboard = false
    @State private var selectedCollaborator: Collaborator? = nil
    @State private var showingPermissionDialog = false
    @State private var showingChat = false
    
    private var registry: Registry? {
        registryRepo.registries.first { $0.id == registryId }
    }
    
    var searchResults: [ProductItem] {
        if searchText.isEmpty {
            return []
        } else {
            return ProductRepository.shared.products.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var suggestedProducts: [ProductItem] {
        guard let registry = registry else { return [] }
        let allProducts = ProductRepository.shared.products
        
        let keywords: [String]
        switch registry.event {
        case .birthday:
            keywords = ["gift", "cake", "party", "sweet", "baking"]
        case .wedding:
            keywords = ["set", "cookware", "electrics", "tabletop", "glass"]
        case .housewarming:
            keywords = ["home", "decor", "essentials", "towels", "pan"]
        case .anniversary:
            keywords = ["wine", "glass", "premium", "gift", "plate"]
        case .other:
            keywords = ["popular", "best", "new", "exclusive"]
        }
        
        let filtered = allProducts.filter { product in
            let titleLower = product.title.lowercased()
            let typeLower = product.productType?.lowercased() ?? ""
            return keywords.contains { titleLower.contains($0) || typeLower.contains($0) }
        }
        
        if filtered.count >= 5 {
            return Array(filtered.shuffled().prefix(6))
        } else {
            return Array(allProducts.shuffled().prefix(6))
        }
    }
    
    var body: some View {
        Group {
            if let registry = registry {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        if searchText.isEmpty {
                            // MARK: - Registry Details
                            
                            headerCard(registry: registry)
                            
                            // Collaborators section
                            if !collabManager.collaborators(for: registryId).isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Collaborators")
                                        .font(.headline)
                                        .padding(.horizontal, 16)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(collabManager.collaborators(for: registryId)) { collaborator in
                                                VStack(spacing: 6) {
                                                    Circle()
                                                        .fill(Color.black)
                                                        .frame(width: 44, height: 44)
                                                        .overlay(
                                                            Text(String(collaborator.name.prefix(2)).uppercased())
                                                                .font(.caption.bold())
                                                                .foregroundColor(.white)
                                                        )
                                                    if collaborator.permission == .full {
                                                        Text("Full")
                                                            .font(.system(size: 9))
                                                            .foregroundColor(.white)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(Color.green)
                                                            .clipShape(Capsule())
                                                    }
                                                }
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    selectedCollaborator = collaborator
                                                    showingPermissionDialog = true
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .confirmationDialog(
                                    "Manage Permissions for \(selectedCollaborator?.name ?? "Collaborator")",
                                    isPresented: $showingPermissionDialog,
                                    titleVisibility: .visible
                                ) {
                                    Button("Full Access") {
                                        if let collab = selectedCollaborator {
                                            collabManager.updatePermission(.full, for: collab.id, in: registryId)
                                        }
                                    }
                                    Button("Limited") {
                                        if let collab = selectedCollaborator {
                                            collabManager.updatePermission(.limited, for: collab.id, in: registryId)
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {}
                                }
                            }
                            
                            // Items List
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Your Items")
                                        .font(.headline)
                                    Spacer()
                                    if registry.items.count >= 5 && !registry.isCategorized {
                                        Button(action: {
                                            withAnimation(.spring(duration: 0.3)) {
                                                registryRepo.toggleCategorized(for: registryId)
                                            }
                                        }) {
                                            Text("Organize by category")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                
                                if registry.items.isEmpty {
                                    emptyItemsView
                                } else {
                                    if registry.isCategorized {
                                        VStack(spacing: 16) {
                                            // Uncategorized Section
                                            if !registry.uncategorizedItems.isEmpty {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    Button {
                                                        withAnimation(.spring(duration: 0.3)) {
                                                            isUncategorizedCollapsed.toggle()
                                                        }
                                                    } label: {
                                                        HStack {
                                                            Image(systemName: isUncategorizedCollapsed ? "chevron.right" : "chevron.down")
                                                                .foregroundColor(.secondary)
                                                                .font(.subheadline)
                                                            
                                                            Text("Uncategorized")
                                                                .font(.headline)
                                                                .foregroundColor(.primary)
                                                            Text("(\(registry.uncategorizedItems.count))")
                                                                .foregroundColor(.secondary)
                                                                .font(.subheadline)
                                                            Spacer()
                                                        }
                                                    }
                                                    .buttonStyle(.plain)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(isUncategorizedTargeted ? Color.black.opacity(0.05) : Color.clear)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(isUncategorizedTargeted ? Color.black : Color.clear, lineWidth: 1)
                                                    )
                                                    
                                                    if !isUncategorizedCollapsed {
                                                        VStack(spacing: 12) {
                                                            ForEach(registry.uncategorizedItems) { item in
                                                                registryItemRow(for: item, in: registryId)
                                                                    .draggable(item.id)
                                                            }
                                                        }
                                                        .padding(.horizontal, 12)
                                                    }
                                                }
                                                .padding(.vertical, 12)
                                                .background(Color.white)
                                                .cornerRadius(12)
                                                .dropDestination(for: String.self) { itemIds, _ in
                                                    withAnimation(.spring(duration: 0.3)) {
                                                        for itemId in itemIds {
                                                            registryRepo.moveItem(itemId: itemId, toCategoryId: nil, in: registryId)
                                                        }
                                                    }
                                                    return true
                                                } isTargeted: { isTargeted in
                                                    isUncategorizedTargeted = isTargeted
                                                }
                                            }
                                            
                                            // Categorized Sections
                                            ForEach(registry.categories) { category in
                                                let categoryItems = registry.items(for: category.id)
                                                let isVisible = !categoryItems.isEmpty || category.isCustom || tappedPredefinedCategoryIds.contains(category.id)
                                                
                                                if isVisible {
                                                    let isCollapsed = collapsedCategoryIds.contains(category.id)
                                                    
                                                    VStack(alignment: .leading, spacing: 12) {
                                                        HStack {
                                                            Button {
                                                                withAnimation(.spring(duration: 0.3)) {
                                                                    if isCollapsed {
                                                                        collapsedCategoryIds.remove(category.id)
                                                                    } else {
                                                                        collapsedCategoryIds.insert(category.id)
                                                                    }
                                                                }
                                                            } label: {
                                                                HStack {
                                                                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                                                                        .foregroundColor(.secondary)
                                                                        .font(.subheadline)
                                                                    
                                                                    Text(category.name)
                                                                        .font(.headline)
                                                                        .foregroundColor(.primary)
                                                                    Text("(\(categoryItems.count))")
                                                                        .foregroundColor(.secondary)
                                                                        .font(.subheadline)
                                                                }
                                                            }
                                                            .buttonStyle(.plain)
                                                            
                                                            Spacer()
                                                            
                                                            if category.isCustom {
                                                                Button(role: .destructive) {
                                                                    withAnimation(.spring(duration: 0.3)) {
                                                                        registryRepo.deleteCustomCategory(categoryId: category.id, from: registryId)
                                                                    }
                                                                } label: {
                                                                    Image(systemName: "trash")
                                                                        .foregroundColor(.red)
                                                                }
                                                            }
                                                        }
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background(targetedCategoryId == category.id ? Color.black.opacity(0.05) : Color.clear)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(targetedCategoryId == category.id ? Color.black : Color.clear, lineWidth: 1)
                                                        )
                                                        
                                                        if !isCollapsed {
                                                            if categoryItems.isEmpty {
                                                                Text("Drag items here")
                                                                    .font(.caption)
                                                                    .foregroundColor(.gray)
                                                                    .padding(.vertical, 12)
                                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                                    .background(Color(.systemGray6))
                                                                    .cornerRadius(8)
                                                                    .padding(.horizontal, 12)
                                                            } else {
                                                                VStack(spacing: 12) {
                                                                    ForEach(categoryItems) { item in
                                                                        registryItemRow(for: item, in: registryId)
                                                                            .draggable(item.id)
                                                                    }
                                                                }
                                                                .padding(.horizontal, 12)
                                                            }
                                                        }
                                                    }
                                                    .padding(.vertical, 12)
                                                    .background(Color.white)
                                                    .cornerRadius(12)
                                                    .dropDestination(for: String.self) { itemIds, _ in
                                                        withAnimation(.spring(duration: 0.3)) {
                                                            for itemId in itemIds {
                                                                registryRepo.moveItem(itemId: itemId, toCategoryId: category.id, in: registryId)
                                                            }
                                                        }
                                                        return true
                                                    } isTargeted: { isTargeted in
                                                        targetedCategoryId = isTargeted ? category.id : nil
                                                    }
                                                }
                                            }
                                            
                                            // Add Category Button
                                            Button {
                                                showingAddCategorySheet = true
                                            } label: {
                                                HStack {
                                                    Image(systemName: "plus.circle.fill")
                                                    Text("Add Category")
                                                }
                                                .font(.headline)
                                                .foregroundColor(.black)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(12)
                                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                            }
                                            .padding(.top, 8)
                                        }
                                        .padding(.horizontal, 16)
                                    } else {
                                        // Standard flat list of items
                                        VStack(spacing: 12) {
                                            ForEach(registry.items) { item in
                                                registryItemRow(for: item, in: registryId)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    
                                    // Add All to Cart Button
                                    Button(action: {
                                        for item in registry.items {
                                            let product = ProductItem(
                                                id: item.id,
                                                title: item.title,
                                                price: item.price,
                                                path: item.imageUrl
                                            )
                                            cartRepo.add(product: product, quantity: item.quantity)
                                        }

                                    }) {
                                        Text("Add All to Cart")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.black)
                                            .cornerRadius(12)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                }
                            }
                            
                            // MARK: - AI Suggestions
                            aiSuggestionsSection
                            
                            // Actions
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Registry")
                                }
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            .padding(.bottom, 24)
                            
                        } else {
                            // MARK: - Search Results
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Search Results")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                
                                if searchResults.isEmpty {
                                    ContentUnavailableView("No products found", systemImage: "magnifyingglass", description: Text("Try adjusting your search."))
                                } else {
                                    VStack(spacing: 12) {
                                        ForEach(searchResults) { product in
                                            RegistryProductSearchRow(product: product, registryId: registryId)
                                                .environmentObject(registryRepo)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .background(Color(.systemGray6).opacity(0.5).ignoresSafeArea())
                .navigationTitle(registry.displayName)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, prompt: "Search products to add...")
                .toolbar {
                    // Share button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            shareToken = collabManager.generateToken(for: registryId)
                            UIPasteboard.general.string = "ws://registry/\(shareToken)"
                            withAnimation { copiedToClipboard = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { copiedToClipboard = false }
                            }
                        }) {
                            Image(systemName: copiedToClipboard ? "checkmark" : "square.and.arrow.up")
                                .foregroundColor(.black)
                        }
                    }
                    
                    // Requests badge button (only if pending requests exist)
                    if !collabManager.pendingRequests(for: registryId).isEmpty {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: CollabRequestsView(registryId: registryId)
                                .environmentObject(registryRepo)
                                .environmentObject(collabManager)) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(.black)
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 4, y: -4)
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddCategorySheet) {
                    AddCategorySheet(
                        registry: registry,
                        registryId: registryId,
                        tappedPredefinedCategoryIds: $tappedPredefinedCategoryIds
                    )
                    .environmentObject(registryRepo)
                }
                .sheet(item: $showingContributionFor) { item in
                    ContributionView(item: item, registryId: registryId)
                        .environmentObject(collabManager)
                }
                .sheet(isPresented: $showingChat) {
                    ChatBotView(viewModel: ChatViewModel(registryRepo: registryRepo, cartRepo: cartRepo, registryId: registryId))
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        showingChat = true
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding()
                }
                .overlay(alignment: .top) {
                    if copiedToClipboard {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Invite code copied!")
                                .font(.subheadline.bold())
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.1), radius: 10)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .confirmationDialog(
                    "Are you sure you want to delete this registry?",
                    isPresented: $showingDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        registryRepo.deleteRegistry(id: registryId)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            } else {
                ContentUnavailableView("Registry not found", systemImage: "tray")
            }
        }
        .onChange(of: registryRepo.registries) { _, _ in
            if registryRepo.registries.first(where: { $0.id == registryId }) == nil {
                dismiss()
            }
        }
    }
    
    @ViewBuilder
    private func registryItemRow(for item: RegistryItem, in registryId: UUID) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            RegistryItemRow(
                viewModel: RegistryItemRowViewModel(
                    item: item,
                    registryId: registryId,
                    registryRepo: registryRepo,
                    cartRepo: cartRepo,
                    tabbarVM: tabBarVM
                )
            )
            
            // Contribution tags
            let itemContributions = collabManager.contributions(for: item.id, in: registryId)
            if !itemContributions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(itemContributions) { contribution in
                        HStack(spacing: 4) {
                            Image(systemName: contribution.isFullPayment ? "gift.fill" : "dollarsign.circle.fill")
                                .font(.caption2)
                                .foregroundColor(contribution.isFullPayment ? .green : .blue)
                            Text(contribution.isFullPayment ?
                                 "Gifted by \(contribution.contributorName)" :
                                 "Contributed \(contribution.amount.formatted(.currency(code: "USD"))) by \(contribution.contributorName)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
            
            Button(action: { showingContributionFor = item }) {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle")
                        .font(.caption)
                    Text("Contribute or Gift")
                        .font(.caption)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
    
    private var emptyItemsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "basket")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            Text("No items added yet")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var aiSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .font(.title3)
                Text("AI Suggestions")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 16)
            
            Text("Trending items people generally order for a \(registry?.event.title.lowercased() ?? "event").")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(suggestedProducts) { product in
                        RegistrySuggestionCard(product: product, registryId: registryId)
                            .environmentObject(registryRepo)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }
    
    private func headerCard(registry: Registry) -> some View {
        VStack(spacing: 16) {
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
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(registry.displayName)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(registry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(registry.event.title)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                }
                Spacer()
            }
            
            Divider()
            

            
            // MARK: - Budget Section
            if let budget = registry.targetBudget {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Registry Total")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(registry.totalValue.formatted(.currency(code: "USD"))) / \(budget.formatted(.currency(code: "USD")))")
                            .font(.subheadline)
                            .fontWeight(registry.totalValue > budget ? .bold : .medium)
                            .foregroundColor(registry.totalValue > budget ? .red : .primary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray6))
                                .frame(height: 8)
                            
                            let percentage = min(registry.totalValue / budget, 1.0)
                            Capsule()
                                .fill(registry.totalValue > budget ? Color.red : Color.black)
                                .frame(width: geometry.size.width * CGFloat(percentage), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    if registry.totalValue > budget {
                        Text("You have exceeded your target budget.")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

// MARK: - Add Category Sheet
struct AddCategorySheet: View {
    let registry: Registry
    let registryId: UUID
    @Binding var tappedPredefinedCategoryIds: Set<UUID>
    @EnvironmentObject var registryRepo: RegistryRepository
    @Environment(\.dismiss) private var dismiss
    
    @State private var isCreatingCustom = false
    @State private var customName = ""
    
    var inactivePredefinedCategories: [RegistryCategory] {
        registry.categories.filter { !$0.isCustom && registry.items(for: $0.id).isEmpty && !tappedPredefinedCategoryIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isCreatingCustom {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Category Name")
                            .font(.headline)
                        
                        TextField("e.g. Backyard Party", text: $customName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Button {
                            if !customName.isEmpty {
                                _ = registryRepo.addCustomCategory(name: customName, to: registryId)
                                dismiss()
                            }
                        } label: {
                            Text("Create Category")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(customName.isEmpty ? Color.gray : Color.black)
                                .cornerRadius(12)
                        }
                        .disabled(customName.isEmpty)
                        
                        Spacer()
                    }
                    .padding(24)
                    .navigationTitle("New Custom Category")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                isCreatingCustom = false
                            }
                        }
                    }
                } else {
                    List {
                        if inactivePredefinedCategories.isEmpty {
                            Section {
                                Text("All predefined categories are active.")
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Section(header: Text("Predefined Categories")) {
                                ForEach(inactivePredefinedCategories) { category in
                                    Button {
                                        tappedPredefinedCategoryIds.insert(category.id)
                                        dismiss()
                                    } label: {
                                        HStack {
                                            Text(category.name)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section {
                            Button {
                                isCreatingCustom = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Create custom category")
                                }
                                .font(.headline)
                                .foregroundColor(.black)
                            }
                        }
                    }
                    .navigationTitle("Add Category")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Search Row View
struct RegistryProductSearchRow: View {
    let product: ProductItem
    let registryId: UUID
    @EnvironmentObject var registryRepo: RegistryRepository
    
    var quantityInRegistry: Int {
        guard let registry = registryRepo.registries.first(where: { $0.id == registryId }),
              let item = registry.items.first(where: { $0.id == product.id }) else {
            return 0
        }
        return item.quantity
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image
            AsyncImage(url: product.imageURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                if let price = product.price {
                    Text(price.formatted(.currency(code: "USD")))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            // Quantity Controls
            HStack(spacing: 12) {
                Button {
                    registryRepo.decreaseQty(product.id, for: registryId)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(quantityInRegistry > 0 ? .black : .gray)
                        .frame(width: 28, height: 28)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .disabled(quantityInRegistry == 0)
                
                Text("\(quantityInRegistry)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(minWidth: 20)
                
                Button {
                    if quantityInRegistry == 0 {
                        // First time adding - Auto-match predefined category
                        let matchedCategory = RegistryCategory.matchingCategory(for: product.pattern)
                        let registry = registryRepo.registries.first { $0.id == registryId }
                        let categoryId = registry?.categories.first { $0.name == matchedCategory?.name }?.id
                        
                        let newItem = RegistryItem(
                            id: product.id,
                            title: product.title,
                            price: product.price ?? 0.0,
                            imageUrl: product.path,
                            quantity: 1,
                            categoryId: categoryId
                        )
                        registryRepo.addProduct(newItem, to: registryId)
                    } else {
                        // Already added, just increment
                        registryRepo.increaseQty(product.id, for: registryId)
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.black)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - AI Suggestion Card View
struct RegistrySuggestionCard: View {
    let product: ProductItem
    let registryId: UUID
    @EnvironmentObject var registryRepo: RegistryRepository
    
    var isAdded: Bool {
        guard let registry = registryRepo.registries.first(where: { $0.id == registryId }) else { return false }
        return registry.items.contains(where: { $0.id == product.id })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product Image
            AsyncImage(url: product.imageURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Product Info
            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(2)
                    .frame(height: 36, alignment: .topLeading)
                
                HStack(alignment: .center) {
                    if let price = product.price {
                        Text(price.formatted(.currency(code: "USD")))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Button {
                        if !isAdded {
                            // Auto-match predefined category
                            let matchedCategory = RegistryCategory.matchingCategory(for: product.pattern)
                            let registry = registryRepo.registries.first { $0.id == registryId }
                            let categoryId = registry?.categories.first { $0.name == matchedCategory?.name }?.id
                            
                            let newItem = RegistryItem(
                                id: product.id,
                                title: product.title,
                                price: product.price ?? 0.0,
                                imageUrl: product.path,
                                quantity: 1,
                                categoryId: categoryId
                            )
                            registryRepo.addProduct(newItem, to: registryId)
                        }
                    } label: {
                        Image(systemName: isAdded ? "checkmark" : "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isAdded ? .gray : .black)
                            .frame(width: 28, height: 28)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .disabled(isAdded)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
        }
        .frame(width: 140)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}
