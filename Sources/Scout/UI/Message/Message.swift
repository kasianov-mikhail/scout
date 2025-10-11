//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Message: Equatable {
    let text: String
    let level: Level

    init(_ text: String, level: Level) {
        self.text = text
        self.level = level
    }
}

extension View {
    func message(_ message: Binding<Message?>) -> some View {
        modifier(MessageView.Presenter(message: message))
    }

    func navigationMessage(_ message: Message?) -> some View {
        preference(key: Message.Key.self, value: message)
    }
}

extension Message {
    struct Key: PreferenceKey {
        static let defaultValue: Message? = nil

        static func reduce(value: inout Message?, nextValue: () -> Message?) {
            value = nextValue()
        }
    }
}
