import Foundation

struct ProductImageResolver {
    static func resolveImageURL(forTitle title: String, path: String?) -> URL? {
        guard let url = path else { return nil }
        
        // If it's a placeholder, resolve it to a gorgeous Unsplash kitchen image based on categories
        if url.contains("example.com") || url.contains("placeholder") || url.isEmpty {
            let lower = title.lowercased()
            if lower.contains("pan") || lower.contains("pot") || lower.contains("cookware") || lower.contains("dutch oven") || lower.contains("skillet") || lower.contains("saucepan") || lower.contains("fry") {
                // Cookware
                return URL(string: "https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?q=80&w=600&auto=format&fit=crop")
            } else if lower.contains("glass") || lower.contains("goblet") || lower.contains("wine") || lower.contains("champagne") {
                // Glasses / Tabletop
                return URL(string: "https://images.unsplash.com/photo-1535401991746-da3d9055713e?q=80&w=600&auto=format&fit=crop")
            } else if lower.contains("plate") || lower.contains("dinnerware") || lower.contains("bowl") || lower.contains("stoneware") || lower.contains("porcelain") || lower.contains("ceramic") {
                // Dinnerware
                return URL(string: "https://images.unsplash.com/photo-1540555700478-4be289fbecef?q=80&w=600&auto=format&fit=crop")
            } else if lower.contains("knife") || lower.contains("cutlery") || lower.contains("chef") {
                // Knives
                return URL(string: "https://images.unsplash.com/photo-1593113598332-cd288d649433?q=80&w=600&auto=format&fit=crop")
            } else if lower.contains("coffee") || lower.contains("espresso") || lower.contains("maker") || lower.contains("machine") {
                // Coffee Maker
                return URL(string: "https://images.unsplash.com/photo-1517256064527-09c53b2d0c6b?q=80&w=600&auto=format&fit=crop")
            } else if lower.contains("oven") || lower.contains("pizza") || lower.contains("toaster") || lower.contains("blender") || lower.contains("juicer") || lower.contains("mixer") {
                // Electrics / Pizza oven
                return URL(string: "https://images.unsplash.com/photo-1516685018646-549198525c1b?q=80&w=600&auto=format&fit=crop")
            } else if lower.contains("bbq") || lower.contains("grill") || lower.contains("basket") || lower.contains("tool") || lower.contains("utensil") || lower.contains("peel") {
                // Tools / BBQ
                return URL(string: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=600&auto=format&fit=crop")
            } else if lower.contains("stand") || lower.contains("cake") || lower.contains("bakery") || lower.contains("baking") || lower.contains("sheet") {
                // Cake Stand / Bakeware
                return URL(string: "https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=600&auto=format&fit=crop")
            }
            // Default premium kitchen image
            return URL(string: "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?q=80&w=600&auto=format&fit=crop")
        }
        
        // Normal image path resolution
        if url.hasPrefix("http://") || url.hasPrefix("https://") || url.hasPrefix("file://") {
            return URL(string: url)
        }
        return URL(string: AppConstants.API.imageBasePath + url)
    }
}
