//
//  ChatView.swift
//  AppleLLMChat
//
//  Created by Geetam Singh on 06/02/26.
//

import SwiftUI

/// Main chat interface view
struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Show unavailable view if model is not ready
            if !viewModel.isModelAvailable, let reason = viewModel.unavailableReason {
                UnavailableView(reason: reason) {
                    viewModel.checkModelAvailability()
                }
            } else {
                // Messages list or empty state (Flexible height)
                if let conversation = viewModel.currentConversation, !conversation.messages.isEmpty {
                    messagesListView(conversation: conversation)
                } else {
                    emptyStateView
                }
                
                // Error message banner (for runtime errors)
                if viewModel.isModelAvailable, let error = viewModel.errorMessage {
                    errorBanner(message: error)
                }
                
                // Input area (Directly in VStack for better keyboard avoidance)
                if viewModel.isModelAvailable && viewModel.unavailableReason == nil {
                    ChatInputView(
                        text: $viewModel.inputText,
                        isGenerating: viewModel.isGenerating
                    ) {
                        Task {
                            await viewModel.sendMessage()
                        }
                    }
                }
            }
        }
        .background(backgroundView.ignoresSafeArea())
        .navigationTitle(viewModel.currentConversation?.title ?? "New Chat")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                modelStatusIndicator
            }
        }
        .onAppear {
            viewModel.checkModelAvailability()
        }
    }
    
    // MARK: - Subviews
    
    private func messagesListView(conversation: Conversation) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(conversation.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isGenerating: viewModel.isGenerating && message == conversation.messages.last && !message.isFromUser
                        )
                        .id(message.id)
                    }
                }
                .padding(.vertical, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: conversation.messages.count) { _, _ in
                scrollToBottom(proxy: proxy, conversation: conversation)
            }
            .onChange(of: conversation.messages.last?.content) { _, _ in
                scrollToBottom(proxy: proxy, conversation: conversation)
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, conversation: Conversation) {
        withAnimation(.spring(response: 0.3)) {
            if let lastMessage = conversation.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animated logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "apple.intelligence")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 12) {
                Text("Apple Intelligence")
                    .font(.title.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Ask me anything. I run entirely on your device,\nkeeping your conversations private.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
        .scrollDismissesKeyboard(.interactively)
    }
    
    private func errorBanner(message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Spacer()
            Button("Dismiss") {
                viewModel.errorMessage = nil
            }
            .font(.caption.bold())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.1))
    }
    
    private var modelStatusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(viewModel.isModelAvailable ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            Text(viewModel.isModelAvailable ? "Ready" : (viewModel.unavailableReason?.title ?? "Loading"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        #if os(macOS)
        LinearGradient(
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .windowBackgroundColor).opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        #else
        LinearGradient(
            colors: [
                Color(uiColor: .systemBackground),
                Color(uiColor: .secondarySystemBackground).opacity(0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        #endif
    }

}

#Preview {
    NavigationStack {
        ChatView(viewModel: ChatViewModel())
    }
}
