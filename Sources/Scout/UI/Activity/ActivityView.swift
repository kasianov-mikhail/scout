//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import Charts

struct ActivityView: View {
    @State var extent: ChartExtent<ActivityPeriod>
    @ObservedObject var activity: ActivityProvider

    init(activity: ActivityProvider, period: ActivityPeriod) {
        self.activity = activity
        self._extent = State(wrappedValue: ChartExtent(period: period))
    }

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(extent: $extent, periods: ActivityPeriod.allCases)

            if let data = activity.data {
                RangeControl(extent: $extent)
                    .padding(.top)
                    .padding(.horizontal)

                let points = extent.segment(from: data)

                List {
                    ChartView(points: points, extent: extent)
                        .foregroundStyle(.green)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
            } else {
                ProgressView().tint(nil).frame(maxHeight: .infinity)
            }
        }
        .navigationTitle("Active Users")
    }
}
