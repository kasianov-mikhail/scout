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

    var body: some View {
        ProviderView(provider: activity) { data in
            let points = data.points(on: extent.period)
            let segment = extent.segment(from: points)
            let canCompare = extent.canCompare(points: points, segment: segment)

            InsetList {
                PeriodPicker(extent: $extent, title: \.rawValue)
                    .listRowSeparator(.hidden)

                RangeControl(extent: $extent)
                    .padding(.bottom)
                    .listRowSeparator(.hidden)

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ChartExportButton(
                        title: "Active Users",
                        rangeLabel: extent.domain.label(using: rangeDateFormatter)
                    ) {
                        ChartView(segment: segment, timing: extent)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .navigationTitle(en: "Active Users")
    }
}

#Preview("ActivityView") {
    NavigationStack {
        ActivityView(
            activity: .init(.success([])),
            period: .daily
        )
    }
}
