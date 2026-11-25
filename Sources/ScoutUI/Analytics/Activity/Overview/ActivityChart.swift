//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct ActivityChart: View {
    let series: ActivitySeries

    var body: some View {
        let values = series.values
        let formatter = DateFormatter.monthDay
        let middle = values.dropFirst((values.count - 1) / 2).first

        return BarChart(
            values: values.map(\.value),
            startLabel: values.first.map { formatter.string(from: $0.date) } ?? "",
            middleLabel: middle.map { formatter.string(from: $0.date) },
            endLabel: "today",
            height: 96,
            spacing: 2,
            cornerRadius: 0,
            labelGap: 6,
            labelDesign: .monospaced,
            accent: values.indices.last.map { BarChart.Accent(index: $0, color: .fillSuccess) }
        )
    }
}

#Preview {
    ActivityChart(
        series: ActivitySeries(
            points: ActivityPoint.samples,
            metric: .daily,
            now: Date()
        )
    )
    .padding()
}

extension Color {
    static let trendPositive = textSuccess
    static let trendTrack = tintSuccess
}
