//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

enum TimelineFixture {
    static let baseDate = Date(timeIntervalSince1970: 1_700_000_000)

    static func at(_ offset: TimeInterval) -> Date {
        baseDate.addingTimeInterval(offset)
    }
}
