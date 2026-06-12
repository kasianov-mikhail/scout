//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Logging
import SwiftUI

extension Event {
    typealias Level = Logger.Level
}

extension Event.Level {
    var descriptionText: Text {
        Text(description.uppercased()).foregroundColor(color ?? .blue)
    }

    var description: String {
        switch self {
        case .notice:
            "Notice"
        case .debug:
            "Debug"
        case .trace:
            "Trace"
        case .info:
            "Info"
        case .warning:
            "Warning"
        case .error:
            "Error"
        case .critical:
            "Critical"
        }
    }

    var color: Color? {
        switch self {
        case .notice, .debug, .trace, .info:
            nil
        case .warning, .error:
            .yellow
        case .critical:
            .red
        }
    }
}
