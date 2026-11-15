//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct HomeActiveUsersChart: View {
    let metric: ActiveUsersMetric
    let start: Date
    let end: Date

    var body: some View {
        BarChart(
            values: metric.series,
            startLabel: DateFormatter.monthDay.string(from: start),
            middleLabel: DateFormatter.monthDay.string(from: middle),
            endLabel: "today",
            height: 72,
            spacing: .space2,
            cornerRadius: .radiusBar,
            labelGap: 6,
            labelDesign: .monospaced,
            accent: metric.series.indices.last.map { BarChart.Accent(index: $0, color: metric.kind.accent) },
            roundBottomCorners: false
        )
    }

    private var middle: Date {
        start.addingTimeInterval(end.timeIntervalSince(start) / 2)
    }
}

#Preview {
    HomeActiveUsersChart(metric: ActiveUsers.sample.metrics[0], start: ActiveUsers.sample.start, end: ActiveUsers.sample.end)
        .padding()
}
