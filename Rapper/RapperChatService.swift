//
//  RapperChatService.swift
//  Rapper
//
//  Created by Sing Hui Hang on 17/10/25.
//


import Foundation
import OpenAI

class RapperChatService{
    
    init() {
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !key.isEmpty else { fatalError("⚠️ OPENAI_API_KEY not set in environment")
        }
        let configuration = OpenAI.Configuration(token: key)
        self.openAI = OpenAI(configuration: configuration)
    }
    
    
    private let openAI: OpenAI
    
    private let systemPrompt = "You are Elmo from Sesame Street, but Gen-Z version. Answer with playful, witty rap bars packed with internal rhymes, Singlish slang, and good vibes.. Keep it to just 3 lines, avoid profanity, but don't be too cringey. Make it mic drop at the end!"
    
    func respond(to text: String) async throws -> String{
        
        let query = ChatQuery(
            messages: [.system(.init(content: .textContent(systemPrompt))), .user(.init(content: .string(text)))],
            model: .gpt5
        )
        
        let result = try await openAI.chats(query: query)
        
        let response = result.choices.first?.message.content ?? ""
        
//        print("response from chatgpt elmo", response)
        return response
    }

}
