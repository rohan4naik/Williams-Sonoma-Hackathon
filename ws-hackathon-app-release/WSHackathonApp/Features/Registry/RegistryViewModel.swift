//
//  RegistryViewModel.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 05/04/26.
//
import Foundation
import Combine
import SwiftUI
 
@MainActor
final class RegistryViewModel: ObservableObject {
    
    @Published private(set) var allRegistries: [Registry] = []
    @Published private(set) var activeRegistryId: UUID?
    
    private var repository: RegistryRepository?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Bind Repository
    
    func bind(repository: RegistryRepository) {
        self.repository = repository
        
        repository.$registries
            .receive(on: RunLoop.main)
            .assign(to: &$allRegistries)
            
        repository.$activeRegistryId
            .receive(on: RunLoop.main)
            .assign(to: &$activeRegistryId)
    }
    
    // MARK: - Computed
    
    var hasRegistries: Bool {
        !allRegistries.isEmpty
    }
    
    var activeRegistry: Registry? {
        allRegistries.first { $0.id == activeRegistryId }
    }
    
    func registry(for id: UUID) -> Registry? {
        allRegistries.first { $0.id == id }
    }
    
    // Helper computed props for the active registry
    var displayTitle: String {
        activeRegistry?.displayName ?? ""
    }
    
    var displayDate: String {
        guard let date = activeRegistry?.date else { return "" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var activeImageData: Data? {
        activeRegistry?.imageData
    }
    
    var activeItems: [RegistryItem] {
        activeRegistry?.items ?? []
    }
    
    var hasItems: Bool {
        !activeItems.isEmpty
    }
    
    // MARK: - Actions
    
    func deleteRegistry(id: UUID) {
        repository?.deleteRegistry(id: id)
    }
    
    func setActiveRegistry(id: UUID?) {
        repository?.setActiveRegistry(id: id)
    }
    
    // MARK: - Instructions
    
    var instructions: [RegistryInstruction] {
        [
            RegistryInstruction(
                title: AppStrings.Registry.exclusiveProduct,
                description: AppStrings.Registry.exclusiveProductsDesc,
                iconName: "star",
                detailedTitle: AppStrings.Registry.exclusiveProduct,
                detailedDescription: AppStrings.Registry.exclusiveProductsDesc
            ),
            RegistryInstruction(
                title: AppStrings.Registry.expertAdvice,
                description: AppStrings.Registry.expertAdviceDesc,
                iconName: "bubble.left",
                detailedTitle: AppStrings.Registry.expertAdvice,
                detailedDescription: AppStrings.Registry.expertAdviceDesc
            ),
            RegistryInstruction(
                title: AppStrings.Registry.discountTitle,
                description: AppStrings.Registry.discountDesc,
                iconName: "dollarsign.circle",
                detailedTitle: AppStrings.Registry.discountTitle,
                detailedDescription: AppStrings.Registry.discountDesc
            ),
            RegistryInstruction(
                title: AppStrings.Registry.inStoreTitle,
                description: AppStrings.Registry.instStoreDesc,
                iconName: "house",
                detailedTitle: AppStrings.Registry.inStoreTitle,
                detailedDescription: AppStrings.Registry.instStoreDesc
            )
        ]
    }
    
    // MARK: - Steps
    
    var steps: [RegistryStep] {
        [
            RegistryStep(
                number: 1,
                title: "Create Your Registry",
                description: "Sign up and set up your event details."
            ),
            RegistryStep(
                number: 2,
                title: "Add Your Favorites",
                description: "Browse and add products you love."
            ),
            RegistryStep(
                number: 3,
                title: "Share With Guests",
                description: "Share your registry link with family and friends."
            )
        ]
    }
}
