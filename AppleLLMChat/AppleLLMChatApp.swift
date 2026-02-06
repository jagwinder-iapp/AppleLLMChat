//
//  AppleLLMChatApp.swift
//  AppleLLMChat
//
//  Created by Geetam Singh on 06/02/26.
//

import SwiftUI

@main
struct AppleLLMChatApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 650)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Chat") {
                    NotificationCenter.default.post(name: .newConversation, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
        }
        #endif
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}

// MARK: - Settings View (macOS)
#if os(macOS)
struct SettingsView: View {
    var body: some View {
        Form {
            Section("About") {
                LabeledContent("Version", value: "1.0")
                LabeledContent("Runtime", value: "On-Device AI")
            }
            
            Section("Privacy") {
                Text("All conversations are processed entirely on your device using Apple's Foundation Models. Your data never leaves your device.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 200)
    }
}
#endif

// MARK: - Notification Names
extension Notification.Name {
    static let newConversation = Notification.Name("newConversation")
}
