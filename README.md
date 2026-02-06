# Apple Intelligence Chat

A private, on-device AI chat application built for the future of Apple platforms. This app leverages the powerful **FoundationModels** framework to provide a ChatGPT-like experience running entirely locally on your device—ensuring maximum privacy and zero latency.


## 🚀 Key Features

*   **100% On-Device:** Powered by Apple's `SystemLanguageModel`, ensuring your data never leaves your device.
*   **Multiplatform:** Seamlessly optimized for iOS, iPadOS, and macOS.
*   **Privacy First:** No internet connection required for inference. No data tracking.
*   **Modern Design:** Built with the latest SwiftUI (Glassmorphism, animated gradients, robust keyboard handling).
*   **Chat History:** Persists conversations locally using secure storage.

## 🛠 Requirements

*   **Xcode:** Version 26.0+ (Beta or Release)
*   **macOS:** Version 26.0+
*   **iOS:** Version 26.0+
*   **Hardware:** Mac, iPad, or iPhone with Apple Intelligence support (M-Series or A17 Pro chips and newer).

## 📦 Installation

1.  Clone this repository:
2.  Open `AppleLLMChat.xcodeproj` in Xcode 26+.
3.  Ensure your target device is selected (Simulator or Real Device).
    *   *Note: For on-device inference, a physical device with Apple Intelligence enabled is recommended.*
4.  Build and Run (`Cmd + R`).

## 🏗 Architecture

The app follows a modern MVVM architecture with strict separation of concerns:

*   **Views:** Pure SwiftUI views (`ChatView`, `ConversationListView`) focusing on declarative UI and animations.
*   **ViewModels:** `ChatViewModel` manages state, model availability checks, and streaming logic using Swift Concurrency (`async/await`).
*   **Framework:** deeply integrated with `FoundationModels` and `LanguageModelSession` for native AI performance.

### Key Components
*   `ChatView`: The main chat interface with auto-scrolling and intelligent keyboard avoidance.
*   `SystemLanguageModel`: The core API driving the intelligence.
*   `ChatInputView`: A robust input bar that lifts seamlessly with the keyboard.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
