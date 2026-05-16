//
//  CreateRegistryView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 04/04/26.
//

import SwiftUI

import SwiftUI

struct CreateRegistryView: View {
    
    @StateObject private var viewModel = CreateRegistryViewModel()
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var registryRepo: RegistryRepository
    
    @State private var navigateToSuccess = false
    
    private let spacing: CGFloat = 16
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                // MARK: - Header
                VStack(spacing: 8) {
                    Text(AppStrings.Registry.createYourRegistry)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text("Enter your details to get started.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // MARK: - Form fields
                VStack(spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personal Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextField(AppStrings.Registry.firstName, text: $viewModel.firstName)
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        
                        TextField(AppStrings.Registry.lastName, text: $viewModel.lastName)
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Details")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            Text(AppStrings.Registry.event)
                                .foregroundColor(.gray)
                            Spacer()
                            Picker(AppStrings.Registry.event, selection: $viewModel.selectedEvent) {
                                ForEach(RegistryEvent.allCases) { event in
                                    Text(event.title).tag(event)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        HStack {
                            Text(AppStrings.Registry.eventDate)
                                .foregroundColor(.gray)
                            Spacer()
                            DatePicker(
                                "",
                                selection: $viewModel.date,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                // MARK: - Create Button
                Button(action: {
                    registryRepo.createRegistry(
                        firstName: viewModel.firstName,
                        lastName: viewModel.lastName,
                        event: viewModel.selectedEvent,
                        date: viewModel.date
                    )
                    navigateToSuccess = true
                }) {
                    Text(AppStrings.Registry.createButton)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.isValid ? Color.black : Color.gray.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(!viewModel.isValid)
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.bottom, 32)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToSuccess) {
            RegistrySuccessView()
        }
    }
}

#Preview {
    CreateRegistryView()
}
