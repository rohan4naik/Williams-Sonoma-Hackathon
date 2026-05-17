import SwiftUI

@MainActor
struct ChatMessageBubble: View {
    let message: GrokChatMessage
    @ObservedObject var viewModel: ChatViewModel
    
    var isUser: Bool {
        message.role == "user"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !isUser {
                // Circular AI Assistant Avatar Icon
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.purple)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.top, 4)
            }
            
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
                let elements = viewModel.parseMessage(message.content)
                
                ForEach(elements, id: \.self) { element in
                    switch element {
                    case .text(let text):
                        Text(text)
                            .padding(12)
                            .background(isUser ? Color.black : Color(.systemGray6))
                            .foregroundColor(isUser ? .white : .primary)
                            .cornerRadius(16)
                            
                    case .product(let title, let price, let url):
                        ChatProductCard(title: title, price: price, imageUrl: url) {
                            viewModel.addToRegistry(title: title, price: price, imageUrl: url)
                        }
                    }
                }
            }
            
            if !isUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

@MainActor
struct ChatProductCard: View {
    let title: String
    let price: Double
    let imageUrl: String
    let onAdd: () -> Void
    
    @State private var isAdded = false
    
    var imageURL: URL? {
        ProductImageResolver.resolveImageURL(forTitle: title, path: imageUrl)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: imageURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else if phase.error != nil {
                    Color.gray.opacity(0.2)
                } else {
                    ProgressView()
                }
            }
            .frame(height: 120)
            .frame(maxWidth: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(2)
                .foregroundColor(.primary)
                .frame(width: 200, alignment: .leading)
            
            HStack {
                Text(price.formatted(.currency(code: "USD")))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    onAdd()
                    isAdded = true
                }) {
                    Image(systemName: isAdded ? "checkmark" : "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isAdded ? .gray : .white)
                        .frame(width: 32, height: 32)
                        .background(isAdded ? Color(.systemGray5) : Color.black)
                        .clipShape(Circle())
                }
                .disabled(isAdded)
            }
            .frame(width: 200)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
