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
    
    @Published private(set) var registry: Registry?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Bind Repository
    
    func bind(repository: RegistryRepository) {
        repository.$currentRegistry
            .receive(on: RunLoop.main)
            .assign(to: &$registry)
    }
    
    // MARK: - Computed
    
    var hasRegistry: Bool {
        registry != nil
    }
    
    var hasItems: Bool {
        !(registry?.items.isEmpty ?? true)
    }
    
    var items: [RegistryItem] {
        registry?.items ?? []
    }
    
    var displayTitle: String {
        registry?.displayName ?? ""
    }
    
    var displayDate: String {
        guard let date = registry?.date else { return "" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
    
    // MARK: - Instructions
    
    var instructions: [RegistryInstruction] {
        [
            RegistryInstruction(
                title: AppStrings.Registry.exclusiveProduct,
                description: AppStrings.Registry.exclusiveProductsDesc,
                iconName: "star",
                detailedTitle: AppStrings.Registry.exclusiveProduct,
                detailedDescription: AppStrings.Registry.exclusiveProductsDetailedDesc
            ),
            RegistryInstruction(
                title: AppStrings.Registry.expertAdvice,
                description: AppStrings.Registry.expertAdviceDesc,
                iconName: "message",
                detailedTitle: AppStrings.Registry.expertAdvice,
                detailedDescription: AppStrings.Registry.expertAdviceDetailedDesc
            ),
            RegistryInstruction(
                title: AppStrings.Registry.discountTitle,
                description: AppStrings.Registry.discountDesc,
                iconName: "dollarsign",
                detailedTitle: AppStrings.Registry.discountDetailedTitle,
                detailedDescription: AppStrings.Registry.discountDetailedDesc
            ),
            RegistryInstruction(
                title: AppStrings.Registry.inStoreTitle,
                description: AppStrings.Registry.instStoreDesc,
                iconName: "house",
                detailedTitle: AppStrings.Registry.inStoreDetailedTitle,
                detailedDescription: AppStrings.Registry.inStoreDetailedDesc
            )
        ]
    }
    
    var steps: [RegistryStep] {
        [
            RegistryStep(number: 1, title: AppStrings.Registry.step1Title, description: AppStrings.Registry.step1Desc),
            RegistryStep(number: 2, title: AppStrings.Registry.step2Title, description: AppStrings.Registry.step2Desc),
            RegistryStep(number: 3, title: AppStrings.Registry.step3Title, description: AppStrings.Registry.step3Desc)
        ]
    }
    
    // MARK: - Actions
    
    func deleteRegistry(using repository: RegistryRepository) {
        repository.deleteRegistry()
    }
}
