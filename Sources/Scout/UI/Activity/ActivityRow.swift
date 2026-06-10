//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct ActivityRow: View {
    let period: ActivityPeriod
    let color: Color
    var systemImage: String? = nil

    @ObservedObject var activity: ActivityProvider

    var body: some View {
        Row {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                    .frame(width: 24)
            }
            Text(period.title)
                .foregroundColor(.primary)
            Spacer()

            RowSummary(series: series, count: count, color: color)
        } destination: {
            ActivityView(activity: activity, period: period)
        }
    }

    /// Daily activity values; `nil` while the provider is still loading.
    private var days: [ChartPoint<Int>]? {
        try? activity.result?.get()
            .points(on: period)
            .bucket(on: period)
    }

    private var series: MiniChartSeries? {
        days.map { MiniChartSeries(points: $0, range: period.initialRange, aggregation: .latest) }
    }

    private var count: Int? {
        days?.max()?.count
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        List {
            ActivityRow(
                period: .daily,
                color: .green,
                activity: ActivityProvider()
            )
        }
    }
}
