import Foundation

struct GrokChatMessage: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let role: String // "system", "user", "assistant"
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
}

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [GrokChatMessage]
    let temperature: Double
    let stream: Bool
}

struct ChatCompletionResponse: Codable {
    struct Choice: Codable {
        let message: GrokChatMessage
    }
    let choices: [Choice]
}

class GrokAIService {
    static let shared = GrokAIService()
    // Using the provided Groq API key (starts with gsk_)
    private let apiKey = "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"
    
    func sendMessage(messages: [GrokChatMessage]) async throws -> GrokChatMessage {
        // Updated to Groq API endpoint since a Groq key was provided
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body = ChatCompletionRequest(
            model: "llama-3.3-70b-versatile", // Fast and active Groq model
            messages: messages,
            temperature: 0.7,
            stream: false
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("Grok API Error: \(httpResponse.statusCode) - \(errorString)")
            throw URLError(.badServerResponse)
        }
        
        let completion = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let message = completion.choices.first?.message else {
            throw URLError(.cannotDecodeRawData)
        }
        
        return message
    }
}
