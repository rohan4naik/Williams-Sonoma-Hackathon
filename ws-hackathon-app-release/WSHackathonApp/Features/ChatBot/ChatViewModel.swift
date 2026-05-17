import Foundation
import SwiftUI
import Combine

enum ChatElement: Identifiable, Hashable {
    case text(String)
    case product(title: String, price: Double, url: String)
    
    var id: String {
        switch self {
        case .text(let t): return t
        case .product(let t, _, _): return t
        }
    }
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [GrokChatMessage] = []
    @Published var isTyping = false
    
    let registryRepo: RegistryRepository
    let cartRepo: CartRepository
    let activeRegistryId: UUID
    
    init(registryRepo: RegistryRepository, cartRepo: CartRepository, registryId: UUID) {
        self.registryRepo = registryRepo
        self.cartRepo = cartRepo
        self.activeRegistryId = registryId
        
        setupSystemPrompt()
    }
    
    private func setupSystemPrompt() {
        guard let registry = registryRepo.registries.first(where: { $0.id == activeRegistryId }) else { return }
        
        let itemNames = registry.items.map { "\($0.title) ($\($0.price))" }.joined(separator: ", ")
        
        let systemPrompt = """
        You are the official Williams-Sonoma Registry AI Assistant. 
        Your ONLY purpose is to help users build their registries, plan events (like birthdays, weddings), and suggest relevant products.

        STRICT RULES:
        1. NEVER answer questions unrelated to Williams-Sonoma, cooking, home goods, events, or the user's registry.
        2. If the user asks an off-topic question, politely refuse and guide them back to their registry.
        3. Keep your answers concise, friendly, and helpful.
        4. When suggesting a product, ALWAYS check if one of the real catalog items below fits the recommendation. If so, you MUST recommend that item using its exact title, price, and image path.
        5. When suggesting a product, ALWAYS format it exactly like this so the app can render it:
           [PRODUCT: "Product Title" | 150.00 | /img5m.jpg]
           
        AVAILABLE REAL PRODUCTS CATALOG:
        You MUST prioritize recommending these real catalog items whenever appropriate for the user's needs. Use their exact titles, prices, and image paths:
        
        1. "Williams Sonoma End-Grain Cutting Board, Acacia" | Price: 129.95 | ImagePath: /img17m.jpg
        2. "Williams Sonoma Board Oil" | Price: 10.95 | ImagePath: /img27m.jpg
        3. "Hold Everything Lidded Ceramic Bowl, Ashwood, 12\"" | Price: 89.95 | ImagePath: /img64m.jpg
        4. "Apilco Tradition Porcelain Cup & Saucer" | Price: 34.95 | ImagePath: /img95m.jpg
        5. "Staub Enameled Cast Iron Round Dutch Oven, 7-Qt., Basil" | Price: 299.95 | ImagePath: /img83m.jpg
        6. "Cuisinart PerfecTemp Programmable Coffee Maker, 14-cup" | Price: 119.95 | ImagePath: /img122m.jpg
        7. "Hold Everything Lazy Susan, Small, Walnut Finish, 10\"" | Price: 59.95 | ImagePath: /img153m.jpg
        8. "Williams Sonoma Organic House Extra Virgin Olive Oil" | Price: 38.95 | ImagePath: /img4m.jpg
        9. "Dorset Martini Glasses, Set of 4" | Price: 179.80 | ImagePath: /img236m.jpg
        10. "Staub Enameled Cast Iron Traditional Deep Skillet, 8 1/2\", Citron" | Price: 180.00 | ImagePath: /img5m.jpg

        USER CONTEXT:
        Event Type: \(registry.event.title)
        Current Registry Items: \(itemNames.isEmpty ? "None yet." : itemNames)
        """
        
        messages.append(GrokChatMessage(role: "system", content: systemPrompt))
        
        // Add a warm, premium greeting so the screen isn't blank
        messages.append(GrokChatMessage(
            role: "assistant", 
            content: "Hi! I am your Williams-Sonoma Registry Assistant. I'm here to help you find the perfect additions for your \(registry.event.title.lowercased())! Ask me for cookware, dinnerware, event planning tips, or registry suggestions."
        ))
    }
    
    func sendMessage(_ text: String) {
        let userMessage = GrokChatMessage(role: "user", content: text)
        messages.append(userMessage)
        
        Task {
            isTyping = true
            do {
                let responseMessage = try await GrokAIService.shared.sendMessage(messages: messages)
                messages.append(responseMessage)
            } catch {
                print("Chat Error: \(error)")
                messages.append(GrokChatMessage(role: "assistant", content: "Sorry, I'm having trouble connecting to Grok right now."))
            }
            isTyping = false
        }
    }
    
    // Parses a message string into mixed Text and Product elements
    func parseMessage(_ content: String) -> [ChatElement] {
        var elements: [ChatElement] = []
        let pattern = "\\[(?:PRODUCT:\\s*)?\"?([^|]+?)\"?\\s*\\|\\s*\\$?([0-9.]+)\\s*\\|\\s*([^\\]]+)\\]"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [.text(content)]
        }
        
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
        var lastEnd = 0
        
        for match in matches {
            // Add preceding text
            if match.range.location > lastEnd {
                let textRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                if let range = Range(textRange, in: content) {
                    let text = String(content[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty {
                        elements.append(.text(text))
                    }
                }
            }
            
            // Extract product
            if let titleRange = Range(match.range(at: 1), in: content),
               let priceRange = Range(match.range(at: 2), in: content),
               let urlRange = Range(match.range(at: 3), in: content) {
                
                var title = String(content[titleRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                // Clean wrapping quotes from start/end if present
                if title.hasPrefix("\"") && title.hasSuffix("\"") {
                    title = String(title.dropFirst().dropLast())
                }
                // Clean up escaped quotes inside the title
                title = title.replacingOccurrences(of: "\\\"", with: "\"")
                
                let priceStr = String(content[priceRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                let url = String(content[urlRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let price = Double(priceStr) {
                    elements.append(.product(title: title, price: price, url: url))
                }
            }
            
            lastEnd = match.range.location + match.range.length
        }
        
        // Add remaining text
        if lastEnd < content.utf16.count {
            let textRange = NSRange(location: lastEnd, length: content.utf16.count - lastEnd)
            if let range = Range(textRange, in: content) {
                let text = String(content[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty {
                    elements.append(.text(text))
                }
            }
        }
        
        return elements.isEmpty ? [.text(content)] : elements
    }
    
    func addToRegistry(title: String, price: Double, imageUrl: String) {
        let itemId = UUID().uuidString
        let newItem = RegistryItem(
            id: itemId,
            title: title,
            price: price,
            imageUrl: imageUrl,
            quantity: 1,
            categoryId: nil
        )
        registryRepo.addProduct(newItem, to: activeRegistryId)
    }
}
