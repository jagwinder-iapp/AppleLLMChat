//
//  MessageBubbleView.swift
//  AppleLLMChat
//
//  Created by Geetam Singh on 06/02/26.
//

import SwiftUI

/// A chat bubble view for displaying messages
struct MessageBubbleView: View {
    let message: Message
    let isGenerating: Bool
    
    private var isUser: Bool { message.isFromUser }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if isUser {
                Spacer(minLength: 60)
            } else {
                // AI Avatar
                avatarView(
                    icon: "apple.intelligence",
                    colors: [.purple, .blue]
                )
            }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                messageContent
                
                // Timestamp
                timestampView
            }
            
            if isUser {
                // User Avatar
                avatarView(
                    icon: "person.fill",
                    colors: [.orange, .pink]
                )
            } else {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    // MARK: - Subviews
    
    private func avatarView(icon: String, colors: [Color]) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
            
            Image(systemName: icon)
                .font(.system(size: icon == "person.fill" ? 14 : 16, weight: .medium))
                .foregroundStyle(.white)
        }
    }
    
    private var messageContent: some View {
        Group {
            if message.content.isEmpty && isGenerating {
                TypingIndicator()
            } else {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(isUser ? .white : .primary)
                    .textSelection(.enabled)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(bubbleBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                isUser ? Color.clear : Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            LinearGradient(
                colors: [Color.blue, Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color.gray.opacity(0.15)
        }
    }
    
    private var timestampView: some View {
        Text(formattedTime)
            .font(.caption2)
            .foregroundStyle(.secondary)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

/// Typing indicator animation
struct TypingIndicator: View {
    @State private var animatingDots = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animatingDots ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animatingDots
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear {
            animatingDots = true
        }
    }
}

#Preview {
    VStack {
        MessageBubbleView(
            message: Message(content: "Hello! How can I help you today?", isFromUser: false),
            isGenerating: false
        )
        MessageBubbleView(
            message: Message(content: "Tell me about Swift programming", isFromUser: true),
            isGenerating: false
        )
    }
    .padding()
}
