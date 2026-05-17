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
    
    private var apiKey: String {
        // 1. Try to load from Bundle
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["GroqAPIKey"] as? String,
           !key.contains("YOUR_GROQ_API_KEY_HERE") {
            return key
        }
        
        // 2. Try to load from local workspace path directly as fail-safe fallback
        let localPath = "/Users/abhinav/Desktop/Williams-Sonoma-Hackathon/ws-hackathon-app-release/WSHackathonApp/Secrets.plist"
        if let dict = NSDictionary(contentsOfFile: localPath),
           let key = dict["GroqAPIKey"] as? String {
            return key
        }
        
        return ""
    }
    
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
