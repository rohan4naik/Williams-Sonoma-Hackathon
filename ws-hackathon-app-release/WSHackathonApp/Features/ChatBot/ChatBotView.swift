import SwiftUI

@MainActor
struct ChatBotView: View {
    @StateObject var viewModel: ChatViewModel
    @State private var inputText: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages.filter { $0.role != "system" }) { message in
                                ChatMessageBubble(message: message, viewModel: viewModel)
                                    .id(message.id)
                            }
                            
                            if viewModel.isTyping {
                                HStack(alignment: .top, spacing: 10) {
                                    // Circular AI Avatar Icon
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Color.black)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                        .padding(.top, 4)
                                    
                                    TypingIndicatorView()
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .id("typingIndicator")
                            }
                        }
                        .padding(.vertical)
                        .onChange(of: viewModel.messages.count) { _ in
                            if let lastId = viewModel.messages.last?.id {
                                withAnimation {
                                    proxy.scrollTo(lastId, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: viewModel.isTyping) { isTyping in
                            if isTyping {
                                withAnimation {
                                    proxy.scrollTo("typingIndicator", anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                
                // Input Area
                VStack(spacing: 0) {
                    Divider()
                    HStack(alignment: .bottom, spacing: 12) {
                        TextField("Ask for registry suggestions...", text: $inputText, axis: .vertical)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            .lineLimit(1...5)
                        
                        Button {
                            guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            let text = inputText
                            inputText = ""
                            viewModel.sendMessage(text)
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(inputText.isEmpty ? .gray : .black)
                        }
                        .disabled(inputText.isEmpty || viewModel.isTyping)
                    }
                    .padding(12)
                    .background(Color.white)
                }
            }
            .navigationTitle("Registry AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
}

@MainActor
struct TypingIndicatorView: View {
    @State private var anim1 = false
    @State private var anim2 = false
    @State private var anim3 = false
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 8, height: 8)
                .scaleEffect(anim1 ? 1.4 : 0.8)
                .opacity(anim1 ? 1.0 : 0.4)
            Circle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 8, height: 8)
                .scaleEffect(anim2 ? 1.4 : 0.8)
                .opacity(anim2 ? 1.0 : 0.4)
            Circle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 8, height: 8)
                .scaleEffect(anim3 ? 1.4 : 0.8)
                .opacity(anim3 ? 1.0 : 0.4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                anim1 = true
            }
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(0.15)) {
                anim2 = true
            }
            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(0.3)) {
                anim3 = true
            }
        }
    }
}
