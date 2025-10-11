//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension MessageView {
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

// MARK: - Preview

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
