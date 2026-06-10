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
                    chart(data: data)
                        .listRowSeparator(.hidden)

                    ComparisonToggle(isOn: $isComparing)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
            }
        }
        .navigationTitle(en: "Active Users")
    }

    @ViewBuilder func chart(data: [ActivityMatrix]) -> some View {
        let points = data.points(on: extent.period)

        if isComparing {
            ComparisonChartView(
                segment: extent.segment(from: points),
                reference: extent.referenceSegment(from: points),
                timing: extent,
                color: .green
            )
        } else {
            ChartView(segment: extent.segment(from: points), timing: extent)
                .foregroundStyle(.green)
        }
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
