//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Charts
import Scout
import SwiftUI

struct PercentileTrendPoint: Identifiable, Equatable {
    let date: Date
    let p99: TimeInterval

    var id: Date { date }
}

struct PercentileTrendChart: View {
    let trend: [PercentileTrendPoint]
    let unit: Calendar.Component
    let formatter: KeyPath<Double, String>

    var body: some View {
        Chart(trend) { point in
            AreaMark(
                x: .value("Date", point.date, unit: unit),
                y: .value("P99", point.p99)
            )
            .foregroundStyle(
                .linearGradient(
                    colors: [.orange.opacity(0.34), .orange.opacity(0.03)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.monotone)

            LineMark(
                x: .value("Date", point.date, unit: unit),
                y: .value("P99", point.p99)
            )
            .foregroundStyle(.orange)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.monotone)
        }
        .chartYAxis {
            AxisMarks { value in
                if let value = value.as(Double.self) {
                    AxisGridLine()
                    AxisValueLabel(value[keyPath: formatter])
                }
            }
        }
        .aspectRatio(1.618, contentMode: .fit)
    }
}

extension [PercentileTrendPoint] {
    static var sample: [PercentileTrendPoint] {
        let p99s = [
            1.4, 1.2, 1.1, 1.0, 1.1, 1.3, 1.7, 2.4, 2.9, 2.6, 2.2, 2.5,
            2.8, 2.5, 2.3, 2.7, 3.6, 4.1, 3.0, 2.4, 2.0, 1.8, 1.6, 1.5,
        ]

        let start = Calendar.current.startOfDay(for: .now)

        return p99s.enumerated().map { hour, p99 in
            PercentileTrendPoint(date: start.addingTimeInterval(TimeInterval(hour) * .hour), p99: p99)
        }
    }
}

#Preview("PercentileTrendChart") {
    PercentileTrendChart(trend: .sample, unit: .hour, formatter: \TimeInterval.duration)
        .padding(.horizontal)
}
