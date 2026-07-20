//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

private let utcDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "dd.MM.y, HH:mm"
    return formatter
}()

struct UTCTimestampText: View {
    let date: Date
    var size: CGFloat = 16

    var body: some View {
        Text(utcDateFormatter.string(from: date) + " UTC")
            .font(.system(size: size))
            .monospaced()
    }
}
