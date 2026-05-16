//
//  SmartProgressBar.swift
//  WSHackathonApp
//

import SwiftUI

struct SmartProgressBar: View {
    let currentTotal: Double
    let freeShippingThreshold: Double = 150.0
    
    private var progress: Double {
        min(currentTotal / freeShippingThreshold, 1.0)
    }
    
    private var remaining: Double {
        max(freeShippingThreshold - currentTotal, 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "box.truck.fill")
                    .foregroundColor(progress >= 1.0 ? .green : .black)
                
                if progress >= 1.0 {
                    Text("You've unlocked **Free Shipping**!")
                        .font(.subheadline)
                } else {
                    Text("Add **$\(remaining, specifier: "%.2f")** more for **Free Shipping**")
                        .font(.subheadline)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(LinearGradient(colors: [.black, Color(.systemGray2)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SmartProgressBar(currentTotal: 100)
        .padding()
}
