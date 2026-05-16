//
//  RegistrySuccessView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import Foundation
import SwiftUI

struct RegistrySuccessView: View {
    
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.black)
                    
                    Text("Registry Created!")
                        .font(.system(size: 28, weight: .bold))
                }
                
                VStack(spacing: 8) {
                    Text(registryRepo.currentRegistry?.displayName ?? "")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Text("Your registry is ready. Start adding your favorite items.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    tabBarVM.resetRegistryFlow()
                    tabBarVM.selectTab(.home)
                }) {
                    Text("Start Browsing")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
            .padding(.bottom, 40)
        }
        .navigationBarBackButtonHidden(true)
    }
}
