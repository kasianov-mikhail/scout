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

            let model = ChartModel(period: period)
            let count = activity.data?.segment(in: model.viewport).last?.count

            RedactedText(count: count)
        } destination: {
            ActivityView(activity: activity, period: period)
        }
    }
}
