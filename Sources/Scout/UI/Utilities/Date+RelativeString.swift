//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Date {
    var relativeString: String {
        if timeIntervalSinceNow < -60 {
            relativeFormatter.localizedString(for: self, relativeTo: Date())
        } else {
            "recently"
        }
    }
}

nonisolated(unsafe) private let relativeFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.unitsStyle = .abbreviated
    return formatter
}()
