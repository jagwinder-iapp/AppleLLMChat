//
//  UnavailableView.swift
//  AppleLLMChat
//
//  Created by Geetam Singh on 06/02/26.
//

import SwiftUI

/// View displayed when Apple Intelligence is not available
struct UnavailableView: View {
    let reason: ModelUnavailableReason
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: reason.systemImage)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 12) {
                Text(reason.title)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                
                Text(reason.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Action buttons based on reason
            VStack(spacing: 12) {
                if reason == .appleIntelligenceNotEnabled {
                    #if os(macOS)
                    Button {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.siri") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Label("Open Settings", systemImage: "gear")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    #else
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Open Settings", systemImage: "gear")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    #endif
                }
                
                if reason == .modelNotReady {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Downloading...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
                
                Button {
                    onRetry()
                } label: {
                    Label("Check Again", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Not Enabled") {
    UnavailableView(reason: .appleIntelligenceNotEnabled, onRetry: {})
}

#Preview("Downloading") {
    UnavailableView(reason: .modelNotReady, onRetry: {})
}

#Preview("Not Supported") {
    UnavailableView(reason: .deviceNotEligible, onRetry: {})
}
