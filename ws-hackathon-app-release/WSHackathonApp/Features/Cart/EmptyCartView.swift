//
//  EmptyCartView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 05/04/26.
//
import SwiftUI
struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "cart")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            }
            .padding(.top, 60)
            Text("Your Cart is Empty")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer().frame(height: 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.clear)
    }
}
