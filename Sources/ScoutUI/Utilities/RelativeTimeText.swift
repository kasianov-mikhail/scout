//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

// A gray relative-time label ("2m ago") that refreshes every second, anchored
// to a shared `timeline` so rows in the same list tick together.
struct RelativeTimeText: View {
    let date: Date
    let timeline: Date

    var body: some View {
        TimelineView(.periodic(from: timeline, by: 1)) { _ in
            Text(verbatim: date.relativeString)
        }
        .font(.subheadline)
        .foregroundStyle(.gray)
    }
}
