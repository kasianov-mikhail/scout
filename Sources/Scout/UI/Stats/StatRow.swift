//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct StatRow<Destination: View>: View {
    let color: Color
    let period: Period
    var systemImage: String? = nil

    @ObservedObject var stat: StatProvider
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        Row {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                    .frame(width: 24)
            }
            Text(period.title)
                .foregroundColor(systemImage == nil ? color : .primary)
            Spacer()

            RowSummary(series: series, count: count, color: color)
        } destination: {
            destination()
        }
    }

    /// All fetched points; `nil` while the provider is still loading.
    private var points: [ChartPoint<Int>]? {
        try? stat.result?.get().flatMap(\.points)
    }

    private var series: MiniChartSeries? {
        points.map { MiniChartSeries(points: $0, range: period.initialRange, aggregation: .total) }
    }

    private var count: Int? {
        points?.bucket(on: period).total
    }
}

#Preview {
    NavigationStack {
        List {
            StatRow(
                color: .blue,
                period: .today,
                stat: StatProvider(eventName: "event_name", periods: Period.allCases)
            ) {
                Text(verbatim: "Detail")
            }
        }
    }
}
