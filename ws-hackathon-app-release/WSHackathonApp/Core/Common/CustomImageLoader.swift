//
//  CustomImageLoader.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 06/04/26.
//

import SwiftUI
import Combine

final class CustomImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var currentURL: URL?
    
    func load(url: URL?) {
        guard let url else { return }
        guard currentURL != url else { return }
        currentURL = url
        
        Task {
            do {
                let data: Data
                if url.isFileURL {
                    data = try Data(contentsOf: url)
                } else {
                    let (fetchedData, _) = try await URLSession.shared.data(from: url)
                    data = fetchedData
                }
                
                if let img = UIImage(data: data) {
                    await MainActor.run {
                        self.image = img
                    }
                }
            } catch {
                print("Image load failed:", error)
            }
        }
    }
}
