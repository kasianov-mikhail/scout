//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

/// A structure representing a message that can be displayed to the user.
///
/// Messages can have different levels of importance. Each level is associated with a specific color.
///
struct Message: Equatable {
    let text: String
    let level: Level

    init(_ text: String, level: Level) {
        self.text = text
        self.level = level
    }

    enum Level: String, CaseIterable {
        case info
        case warning
        case success
        case error

        var color: Color {
            switch self {
            case .info:
                return .blue
            case .warning:
                return .orange
            case .success:
                return .green
            case .error:
                return .red
            }
        }
    }
}

// MARK: - Modifiers

/// Adds a message overlay to the view.
extension View {

    func message(_ message: Binding<Message?>) -> some View {
        modifier(MessageView.Presenter(message: message))
    }

    func navigationMessage(_ message: Message?) -> some View {
        preference(key: Message.Key.self, value: message)
    }
}

extension Message {

    /// A preference key that stores the message to be displayed.
    ///
    /// This key is used to pass the message up the view hierarchy.
    ///
    struct Key: PreferenceKey {
        static let defaultValue: Message? = nil

        static func reduce(value: inout Message?, nextValue: () -> Message?) {
            value = nextValue()
        }
    }
}

// MARK: - View

/// A view that displays a message to the user.
///
/// The message is displayed as a banner at the top of the view.
/// The message will automatically disappear after a set amount of time.
/// The message can also be hidden manually by setting the message to `nil`.
///
struct MessageView: View {
    let text: String
    let level: Message.Level

    @Environment(\.colorScheme) var colorScheme

    var body: some View {

        Text(text)
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(level.color.opacity(colorScheme == .light ? 0.2 : 0.3))
            .background()
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(level.color, lineWidth: 1)
            }
            .padding(.horizontal)
    }

    /// A view modifier that presents a message to the user.
    struct Presenter: ViewModifier {
        @Binding var message: Message?
        @State private var hideTask: Task<Void, Never>?

        func body(content: Content) -> some View {
            content.overlay(alignment: .top) {
                if let message {
                    MessageView(text: message.text, level: message.level)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onTapGesture {
                            self.message = nil
                        }
                        .gesture(
                            DragGesture().onChanged { _ in
                                self.message = nil
                            }
                        )
                }
            }
            .onChange(of: message) { message in
                hideTask?.cancel()

                if message != nil {
                    hideTask = Task {
                        try? await hideMessage(delay: 5)
                    }
                }
            }
            .animation(.easeInOut, value: message)
        }

        func hideMessage(delay: Int) async throws {
            try await Task.sleep(for: .seconds(delay))
            message = nil
        }
    }
}

// MARK: - Previews

#Preview {
    ForEach(Message.Level.allCases, id: \.self) { level in
        MessageView(text: level.text, level: level)
        MessageView(text: level.longText, level: level)
    }
    .padding(.vertical, 4)
}

@available(iOS 17.0, *)
#Preview("Above the navigation bar") {
    @Previewable @State var message: Message?

    NavigationStack {
        VStack(spacing: 32) {
            Button("Show Info") {
                message = Message(
                    Message.Level.info.text,
                    level: .info
                )
            }

            Button("Show Multiline Warning") {
                message = Message(
                    Message.Level.warning.longText,
                    level: .warning
                )
            }

            Button("Hide") {
                message = nil
            }
            .disabled(message == nil)
        }
        .navigationTitle("Message Presenter")
        .navigationBarTitleDisplayMode(.inline)
    }
    .message($message)
}

/// A set of test messages for use in previews.
extension Message.Level {
    fileprivate var text: String {
        "This is \(article) \(rawValue) message"
    }

    fileprivate var longText: String {
        "This is a long \(rawValue) message that will wrap to multiple lines"
    }

    fileprivate var article: String {
        switch self {
        case .info, .error:
            "an"
        case .warning, .success:
            "a"
        }
    }
}
