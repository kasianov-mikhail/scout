//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct Message: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let level: Level

    init(_ text: String, level: Level) {
        self.text = text
        self.level = level
    }
}

extension View {
    func message(_ message: Binding<Message?>) -> some View {
        modifier(MessagePresenter(message: message))
    }
}

private struct MessagePresenter: ViewModifier {
    @Binding var message: Message?
    @State private var stack: [Message] = []

    private let lifetime: Duration = .seconds(5)

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            VStack(spacing: 8) {
                ForEach(stack) { message in
                    MessageView(text: message.text, level: message.level)
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .move(edge: .top).combined(with: .opacity)
                            )
                        )
                        .onTapGesture {
                            stack.dismiss(message)
                        }
                        .gesture(
                            DragGesture().onChanged { _ in
                                stack.dismiss(message)
                            }
                        )
                        .task {
                            try? await Task.sleep(for: lifetime)
                            guard !Task.isCancelled else { return }
                            stack.dismiss(message)
                        }
                }
            }
        }
        .onChange(of: message) { message in
            guard let message else { return }
            stack.push(message)
            self.message = nil
        }
        .animation(.easeInOut, value: stack)
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Above the navigation bar") {
    @Previewable @State var message: Message?

    NavigationStack {
        VStack(spacing: 32) {
            Button {
                message = Message(
                    Message.Level.info.text,
                    level: .info
                )
            } label: {
                Text(verbatim: "Show Info")
            }

            Button {
                message = Message(
                    Message.Level.warning.longText,
                    level: .warning
                )
            } label: {
                Text(verbatim: "Show Multiline Warning")
            }
        }
        .navigationTitle(en: "Message Presenter")
        .inlineNavigationTitle()
    }
    .message($message)
}
