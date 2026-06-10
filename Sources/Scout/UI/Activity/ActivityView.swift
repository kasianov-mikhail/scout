//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct ActivityView: View {
    @State var extent: ChartExtent<ActivityPeriod>
    @State var comparison: ChartComparison?
    @ObservedObject var activity: ActivityProvider

    init(activity: ActivityProvider, period: ActivityPeriod) {
        self.activity = activity
        self._extent = State(wrappedValue: ChartExtent(period: period))
    }

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(extent: $extent, periods: ActivityPeriod.allCases)

            ProviderView(provider: activity) { data in
                RangeControl(extent: $extent)
                ComparisonPicker(comparison: $comparison)

                List {
                    let points = data.points(on: extent.period)

                    ComparisonChartView(points: points, extent: extent, comparison: comparison)
                        .foregroundStyle(.green)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollDisabled(comparison == nil)
            }
        }
        .navigationTitle(en: "Active Users")
    }
}

// MARK: - Preview

#Preview("ActivityView") {
    let activity = ActivityProvider()
    activity.result = .success([])
    return NavigationStack {
        ActivityView(activity: activity, period: .daily)
    }
}
