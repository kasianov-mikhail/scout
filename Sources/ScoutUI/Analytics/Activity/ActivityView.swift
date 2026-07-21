//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Scout
import SwiftUI

struct ActivityView: View {
    @State var extent: ChartExtent<ActivityPeriod>
    @State private var isComparing = false
    @ObservedObject var activity: ActivityProvider

    init(activity: ActivityProvider, period: ActivityPeriod) {
        self.activity = activity
        self._extent = State(wrappedValue: ChartExtent(period: period))
    }

    init?(activity: ActivityProvider, period: ActivityPeriod?) {
        guard let period else {
            return nil
        }
        self.init(activity: activity, period: period)
    }

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(extent: $extent, periods: ActivityPeriod.allCases)
                .padding(.top)

            ProviderView(provider: activity) { data in
                RangeControl(extent: $extent)
                    .padding(.vertical)

                InsetList {
                    let points = data.points(on: extent.period)
                    let segment = extent.segment(from: points)
                    let canCompare = extent.canCompare(points: points, segment: segment)

                    ComparableChart(
                        segment: segment,
                        points: points,
                        extent: extent,
                        color: .green,
                        isComparing: isComparing
                    )
                    .listRowSeparator(.hidden)
                    .padding(.bottom)

                    ComparisonToggle(isOn: $isComparing).disabled(!canCompare)
                }
                .scrollDisabled(true)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ChartExportButton(
                            title: "Active Users",
                            rangeLabel: extent.domain.label(using: rangeDateFormatter)
                        ) {
                            ChartView(
                                segment: extent.segment(from: data.points(on: extent.period)),
                                timing: extent
                            )
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
