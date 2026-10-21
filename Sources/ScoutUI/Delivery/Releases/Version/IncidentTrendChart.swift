//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Scout
import SwiftUI

struct IncidentTrendSection<Trailing: View>: View {
    let kind: IncidentKind
    let days: [DailyCount]

    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        Header(title: kind.title, trailing: trailing)

        IncidentTrendChart(kind: kind, days: days)
    }
}

struct IncidentTrendChart: View {
    let kind: IncidentKind
    let days: [DailyCount]

    var body: some View {
        let isEmpty = !days.contains(where: { $0.count > 0 })

        Chart(days, id: \.date) { day in
            BarMark(
                x: .value("Day", day.date, unit: .day),
                y: .value("Count", day.count),
                width: .ratio(0.6)
            )
            .foregroundStyle(kind.color.gradient)
            .cornerRadius(3)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: Calendar.Component.day.chartFormat)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .placeholderAxis(active: isEmpty)
        .chartBackground { _ in
            if isEmpty {
                ChartPlaceholder().offset(y: -12)
            }
        }
        .frame(height: 170)
        .environment(\.calendar, .utc)
        .environment(\.timeZone, Calendar.utc.timeZone)
        .listRowSeparator(.hidden)
    }
}
