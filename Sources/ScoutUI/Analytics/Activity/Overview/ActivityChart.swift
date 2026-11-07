//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI

struct ActivityChart: View {
    let series: ActivitySeries

    var body: some View {
        let axis = series.range.axis(now: series.now)

        return BarChart(
            values: series.values.map(\.value),
            startLabel: axis.start,
            middleLabel: axis.middle,
            endLabel: axis.end,
            height: 96,
            spacing: series.range.barSpacing,
            cornerRadius: 0,
            labelGap: 6,
            labelDesign: .monospaced,
            accent: nil
        )
    }
}

#Preview {
    ActivityChart(
        series: ActivitySeries(
            points: ActivityPoint.samples,
            range: .month,
            metric: .daily,
            now: Date()
        )
    )
    .padding()
}
