//
//  CategoryFilterSheet.swift
//  WSHackathonApp
//

import SwiftUI

enum SortOption: String, CaseIterable {
    case newest = "New"
    case priceHighToLow = "Price: High First"
    case priceLowToHigh = "Price: Low First"
}

struct CategoryFilterSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedSort: SortOption
    @Binding var priceRange: Double
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort By")) {
                    Picker("Sort", selection: $selectedSort) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                Section(header: Text("Max Price: \(priceRange.formatted(.currency(code: "USD")))")) {
                    VStack {
                        Slider(value: $priceRange, in: 0...1000, step: 10)
                            .accentColor(.black)
                        
                        HStack {
                            Text("$0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$1000+")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
            }
        }
    }
}
