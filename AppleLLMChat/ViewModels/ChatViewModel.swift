//
//  ChatViewModel.swift
//  AppleLLMChat
//
//  Created by Geetam Singh on 06/02/26.
//

import Foundation
import SwiftUI
import FoundationModels

/// Enum representing different unavailability reasons for better UI handling
enum ModelUnavailableReason {
    case modelNotReady
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case unknown
    
    var title: String {
        switch self {
        case .modelNotReady:
            return "Model Downloading"
        case .deviceNotEligible:
            return "Device Not Supported"
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence Disabled"
        case .unknown:
            return "Unavailable"
        }
    }
    
    var message: String {
        switch self {
        case .modelNotReady:
            return "The on-device AI model is being downloaded. This may take a few minutes."
        case .deviceNotEligible:
            return "This device doesn't support Apple Intelligence. You need an iPhone 15 Pro or later, or a Mac/iPad with M1 chip or later."
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence is not enabled. Please go to Settings → Apple Intelligence & Siri to enable it."
        case .unknown:
            return "The on-device AI model is currently unavailable."
        }
    }
    
    var systemImage: String {
        switch self {
        case .modelNotReady:
            return "arrow.down.circle"
        case .deviceNotEligible:
            return "cpu"
        case .appleIntelligenceNotEnabled:
            return "gear.badge.xmark"
        case .unknown:
            return "exclamationmark.triangle"
        }
    }
}

/// ViewModel managing chat interactions with Apple's on-device Foundation Models
@MainActor
@Observable
class ChatViewModel {
    // MARK: - Properties
    
    var conversations: [Conversation] = []
    var currentConversation: Conversation?
    var inputText: String = ""
    var isGenerating: Bool = false
    var errorMessage: String?
    var isModelAvailable: Bool = false
    var unavailableReason: ModelUnavailableReason?
    
    private var session: LanguageModelSession?
    private let storageKey = "saved_conversations"
    
    // MARK: - Initialization
    
    init() {
        loadConversations()
        checkModelAvailability()
    }
    
    // MARK: - Model Availability
    
    func checkModelAvailability() {
        let availability = SystemLanguageModel.default.availability
        switch availability {
        case .available:
            isModelAvailable = true
            errorMessage = nil
            unavailableReason = nil
        case .unavailable(.modelNotReady):
            isModelAvailable = false
            unavailableReason = .modelNotReady
            errorMessage = unavailableReason?.message
        case .unavailable(.deviceNotEligible):
            isModelAvailable = false
            unavailableReason = .deviceNotEligible
            errorMessage = unavailableReason?.message
        case .unavailable(.appleIntelligenceNotEnabled):
            isModelAvailable = false
            unavailableReason = .appleIntelligenceNotEnabled
            errorMessage = unavailableReason?.message
        case .unavailable:
            isModelAvailable = false
            unavailableReason = .unknown
            errorMessage = unavailableReason?.message
        @unknown default:
            isModelAvailable = false
            unavailableReason = .unknown
            errorMessage = "Unknown availability status."
        }
    }
    
    // MARK: - Conversation Management
    
    func createNewConversation() {
        let conversation = Conversation()
        conversations.insert(conversation, at: 0)
        currentConversation = conversation
        session = LanguageModelSession()
        saveConversations()
    }
    
    func selectConversation(_ conversation: Conversation) {
        currentConversation = conversation
        // Create a new session - we'll need to replay the conversation for context
        session = LanguageModelSession()
    }
    
    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        if currentConversation?.id == conversation.id {
            currentConversation = conversations.first
        }
        saveConversations()
    }
    
    // MARK: - Message Sending
    
    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Check availability before sending
        checkModelAvailability()
        guard isModelAvailable else { return }
        
        let userMessage = Message(content: inputText, isFromUser: true)
        inputText = ""
        
        // Add user message to conversation
        if currentConversation == nil {
            createNewConversation()
        }
        
        currentConversation?.messages.append(userMessage)
        currentConversation?.updatedAt = Date()
        
        // Generate title from first message
        if currentConversation?.messages.count == 1 {
            currentConversation?.generateTitle()
        }
        
        updateConversationInList()
        
        // Create assistant message placeholder for streaming
        var assistantMessage = Message(content: "", isFromUser: false)
        currentConversation?.messages.append(assistantMessage)
        updateConversationInList()
        
        isGenerating = true
        errorMessage = nil
        
        do {
            if session == nil {
                session = LanguageModelSession()
            }
            
            // Use streaming for real-time response
            let stream = session!.streamResponse(to: userMessage.content)
            
            for try await partialResponse in stream {
                assistantMessage.content = partialResponse.content
                
                // Update the message in the conversation
                if let index = currentConversation?.messages.lastIndex(where: { !$0.isFromUser }) {
                    currentConversation?.messages[index] = assistantMessage
                    updateConversationInList()
                }
            }
            
            isGenerating = false
            saveConversations()
            
        } catch {
            isGenerating = false
            errorMessage = "Failed to generate response: \(error.localizedDescription)"
            
            // Remove the empty assistant message on error
            currentConversation?.messages.removeAll { $0.id == assistantMessage.id }
            updateConversationInList()
        }
    }
    
    // MARK: - Persistence
    
    private func updateConversationInList() {
        if let current = currentConversation,
           let index = conversations.firstIndex(where: { $0.id == current.id }) {
            conversations[index] = current
        }
    }
    
    func savePublic() {
        saveConversations()
    }
    
    private func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadConversations() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = decoded
            currentConversation = conversations.first
        }
    }
    
    #if os(macOS)
    func openAppleIntelligenceSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.siri") {
            NSWorkspace.shared.open(url)
        }
    }
    #endif
}
