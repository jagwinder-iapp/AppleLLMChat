//
//  ContentView.swift
//  AppleLLMChat
//
//  Created by Geetam Singh on 06/02/26.
//

import SwiftUI

/// Main content view with navigation split layout
struct ContentView: View {
    @State private var viewModel = ChatViewModel()
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var selectedConversationId: UUID?
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ConversationListView(
                viewModel: viewModel,
                selectedId: $selectedConversationId
            )
            #if os(macOS)
            .frame(minWidth: 250)
            #endif
        } detail: {
            ChatView(viewModel: viewModel)
            #if os(macOS)
            .frame(minWidth: 400)
            #endif
        }
        .onChange(of: selectedConversationId) { _, newId in
            if let id = newId,
               let conversation = viewModel.conversations.first(where: { $0.id == id }) {
                viewModel.selectConversation(conversation)
            }
        }
        .onAppear {
            // Create initial conversation if none exist
            if viewModel.conversations.isEmpty {
                viewModel.createNewConversation()
            }
            selectedConversationId = viewModel.currentConversation?.id
        }
    }
}

#Preview {
    ContentView()
}
