//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension Message {
    enum Level: String, CaseIterable {
        case info
        case warning
        case success
        case error

        var color: Color {
            switch self {
            case .info:
                .blue
            case .warning:
                .orange
            case .success:
                .green
            case .error:
                .red
            }
        }
    }
}

// MARK: - Debug

extension Message.Level {
    var text: String {
        "This is \(article) \(rawValue) message"
    }

    var longText: String {
        "This is a long \(rawValue) message that will wrap to multiple lines"
    }
}

extension Message.Level {
    private var article: String {
        switch self {
        case .info, .error:
            "an"
        case .warning, .success:
            "a"
        }
    }
}
