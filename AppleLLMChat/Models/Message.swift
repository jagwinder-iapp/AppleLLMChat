//
//  Message.swift
//  AppleLLMChat
//
//  Created by Geetam Singh on 06/02/26.
//

import Foundation

/// Represents a single message in a conversation
struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}
