//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ActivityRow: View {
    let period: ActivityPeriod

    @ObservedObject var activity: ActivityProvider

    var body: some View {
        Row {
            Text(period.title)
            Spacer()
            RedactedText(count: .random(in: 1_000...10_000))
        } destination: {
            ActivityView(activity: activity, period: period)
        }
    }
}
