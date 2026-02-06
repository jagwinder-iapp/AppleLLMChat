//
//  ConversationListView.swift
//  AppleLLMChat
//
//  Created by Geetam Singh on 06/02/26.
//

import SwiftUI

/// Sidebar view showing conversation history
struct ConversationListView: View {
    @Bindable var viewModel: ChatViewModel
    @Binding var selectedId: UUID?
    
    @State private var searchText = ""
    
    var body: some View {
        List(selection: $selectedId) {
            ForEach(filteredConversations) { conversation in
                NavigationLink(value: conversation.id) {
                    ConversationRowView(conversation: conversation)
                }
                .contextMenu {
                    Button(role: .destructive) {
                        viewModel.deleteConversation(conversation)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                #if os(iOS)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteConversation(conversation)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                #endif
            }
            #if os(macOS)
            .onDelete { indexSet in
                for index in indexSet {
                    let conversation = filteredConversations[index]
                    viewModel.deleteConversation(conversation)
                }
            }
            #endif
        }
        .listStyle(.sidebar)
        .searchable(text: $searchText, prompt: "Search chats")
        .navigationTitle("Chats")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    let newConversation = Conversation()
                    viewModel.conversations.insert(newConversation, at: 0)
                    viewModel.currentConversation = newConversation
                    viewModel.savePublic()
                    selectedId = newConversation.id
                    searchText = "" // Clear search on new chat
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .help("New Chat")
            }
        }
        .overlay {
            if viewModel.conversations.isEmpty {
                emptyStateOverlay
            }
        }
    }
    
    private var filteredConversations: [Conversation] {
        if searchText.isEmpty {
            return viewModel.conversations
        }
        return viewModel.conversations.filter { conversation in
            conversation.title.localizedCaseInsensitiveContains(searchText) ||
            conversation.messages.contains { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var emptyStateOverlay: some View {
        ContentUnavailableView {
            Label("No Conversations", systemImage: "bubble.left.and.bubble.right")
        } description: {
            Text("Start a new chat to begin")
        } actions: {
            Button {
                viewModel.createNewConversation()
                selectedId = viewModel.currentConversation?.id
            } label: {
                Text("New Chat")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

/// Row view for a single conversation
struct ConversationRowView: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversation.title)
                .font(.headline)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if !conversation.messages.isEmpty {
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text("\(conversation.messages.count) \(conversation.messages.count == 1 ? "message" : "messages")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var formattedDate: String {
        let now = Date()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(conversation.updatedAt) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: conversation.updatedAt)
        } else if calendar.isDateInYesterday(conversation.updatedAt) {
            return "Yesterday"
        } else if let daysAgo = calendar.dateComponents([.day], from: conversation.updatedAt, to: now).day, daysAgo < 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: conversation.updatedAt)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: conversation.updatedAt)
        }
    }
}

#Preview {
    NavigationStack {
        ConversationListView(viewModel: ChatViewModel(), selectedId: .constant(nil))
    }
}
