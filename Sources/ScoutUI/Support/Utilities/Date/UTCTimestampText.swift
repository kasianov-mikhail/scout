//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

private let utcDateFormatter = DateFormatter(format: "dd.MM.y, HH:mm")
private let utcTimeFormatter = DateFormatter(format: "HH:mm")

struct UTCTimestampText: View {
    let date: Date
    var size: CGFloat = 16

    var body: some View {
        Text(utcDateFormatter.string(from: date) + " UTC")
            .font(.system(size: size))
            .monospaced()
    }
}

struct UTCTimeRangeText: View {
    let start: Date
    let end: Date

    var body: some View {
        Text(verbatim: "\(utcDateFormatter.string(from: start)) – \(endText) UTC")
            .font(.system(size: 16))
            .monospaced()
    }

    private var endText: String {
        let formatter = Calendar.utc.isDate(start, inSameDayAs: end) ? utcTimeFormatter : utcDateFormatter
        return formatter.string(from: end)
    }
}
