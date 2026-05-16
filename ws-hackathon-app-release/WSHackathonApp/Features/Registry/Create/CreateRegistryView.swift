//
//  CreateRegistryView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 04/04/26.
//

import SwiftUI
import PhotosUI

struct CreateRegistryView: View {
    
    @StateObject private var viewModel = CreateRegistryViewModel()
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var registryRepo: RegistryRepository
    
    @State private var navigateToSuccess = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isEventPickerExpanded = false
    
    private let spacing: CGFloat = 16
    
    var body: some View {
        ScrollView {
            VStack(spacing: spacing) {
                
                // MARK: - Header
                Text(AppStrings.Registry.createYourRegistry)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 32)
                
                ZStack(alignment: .bottomTrailing) {
                    // Main Circle
                    Group {
                        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                Color.white
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                        }
                    }
                    .frame(width: 140, height: 140)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(UIColor.separator), lineWidth: 0.5))
                    
                    // Small Add/Edit Button
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: selectedImageData == nil ? "plus" : "pencil")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .offset(x: -4, y: -4)
                }
                .padding(.vertical, 16)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
                
                // MARK: - Form fields
                VStack(spacing: 2) {
                    
                    TextField(AppStrings.Registry.firstName, text: $viewModel.firstName)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .frame(height: 46)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.separator), lineWidth: 0.5))
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    
                    TextField(AppStrings.Registry.lastName, text: $viewModel.lastName)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .frame(height: 46)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.separator), lineWidth: 0.5))
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppStrings.Registry.event)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                isEventPickerExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: viewModel.selectedEvent.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                                
                                Text(viewModel.selectedEvent.title)
                                    .foregroundColor(.black)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .rotationEffect(.degrees(isEventPickerExpanded ? 180 : 0))
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        if isEventPickerExpanded {
                            VStack(spacing: 0) {
                                ForEach(RegistryEvent.allCases) { event in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                            viewModel.selectedEvent = event
                                            isEventPickerExpanded = false
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: event.iconName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(.black)
                                            
                                            Text(event.title)
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                            
                                            if viewModel.selectedEvent == event {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        .padding()
                                        .background(.ultraThinMaterial)
                                    }
                                    
                                    if event != RegistryEvent.allCases.last {
                                        Divider()
                                            .overlay(Color.black.opacity(0.1))
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity.combined(with: .move(edge: .top))
                            ))
                        }
                    }
                    .padding(.top, 16)
                    
                    if viewModel.selectedEvent == .other {
                        VStack(spacing: 2) {
                            TextField("Event Title", text: $viewModel.customEventTitle)
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 12)
                                .frame(height: 46)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.separator), lineWidth: 0.5))
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                            
                            TextField("Description", text: $viewModel.customEventDescription, axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .frame(minHeight: 46)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.separator), lineWidth: 0.5))
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                    }
                    
                    HStack {
                        Text(AppStrings.Registry.eventDate)
                            .font(.headline)
                        Spacer()
                        DatePicker(
                            "",
                            selection: $viewModel.date,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                }
                
                // MARK: - Create Button
                Button(action: {
                    registryRepo.createRegistry(
                        firstName: viewModel.firstName,
                        lastName: viewModel.lastName,
                        event: viewModel.selectedEvent,
                        customTitle: viewModel.customEventTitle,
                        date: viewModel.date,
                        imageData: selectedImageData
                    )
                    navigateToSuccess = true
                }) {
                    Text(AppStrings.Registry.createButton)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(!viewModel.isValid)
                .opacity(viewModel.isValid ? 1.0 : 0.6)
                .blur(radius: viewModel.isValid ? 0 : 1.5)
                .animation(.easeInOut, value: viewModel.isValid)
                .padding(.top, 16)
                Spacer()
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToSuccess) {
            RegistrySuccessView()
        }
    }
}

#Preview {
    CreateRegistryView()
}
