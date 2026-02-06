//
//  Conversation.swift
//  AppleLLMChat
//
//  Created by Geetam Singh on 06/02/26.
//

import Foundation

/// Represents a conversation containing multiple messages
struct Conversation: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [Message]
    let createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String = "New Chat", messages: [Message] = [], createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Generate a title from the first message
    mutating func generateTitle() {
        if let firstUserMessage = messages.first(where: { $0.isFromUser }) {
            let preview = String(firstUserMessage.content.prefix(30))
            title = preview + (firstUserMessage.content.count > 30 ? "..." : "")
        }
    }
}
