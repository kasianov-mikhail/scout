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
        let days = days

        SummaryRow(
            title: period.title,
            color: color,
            systemImage: systemImage,
            series: days.map { MiniChartSeries(points: $0, range: period.initialRange, aggregation: .latest) },
            count: days?.max()?.count
        ) {
            ActivityView(activity: activity, period: period)
        }
    }

    /// Daily activity values; `nil` while the provider is still loading.
    private var days: [ChartPoint<Int>]? {
        try? activity.result?.get()
            .points(on: period)
            .bucket(on: period)
    }
}

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
