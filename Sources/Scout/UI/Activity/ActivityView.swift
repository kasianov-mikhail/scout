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
    @State private var isComparing = false
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

                List {
                    let points = data.points(on: extent.period)
                    let segment = extent.segment(from: points)

                    ComparableChart(
                        segment: segment,
                        points: points,
                        extent: extent,
                        color: .green,
                        isComparing: isComparing
                    )
                    .listRowSeparator(.hidden)

                    ComparisonToggle(isOn: $isComparing)
                        .disabled(!extent.canCompare(points: points, segment: segment))
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ChartExportButton(title: "Active Users", rangeLabel: extent.domain.label(using: rangeDateFormatter)) {
                            ChartView(segment: extent.segment(from: data.points(on: extent.period)), timing: extent)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
        .navigationTitle(en: "Active Users")
    }
}

#Preview("ActivityView") {
    let activity = ActivityProvider()
    activity.result = .success([])
    return NavigationStack {
        ActivityView(activity: activity, period: .daily)
    }
}
