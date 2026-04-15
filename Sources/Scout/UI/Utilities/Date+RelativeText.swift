//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension Date {
    var relativeText: Text {
        if timeIntervalSinceNow < -60 {
            Text(relativeFormatter.localizedString(for: self, relativeTo: Date()))
        } else {
            Text("recently")
        }
    }
}

nonisolated(unsafe) private let relativeFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter
}()
