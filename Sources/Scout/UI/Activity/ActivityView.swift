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
                    let segment = extent.segment(from: data)

                    ChartView(segment: segment, timing: extent)
                        .foregroundStyle(.green)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
            }
        }
        .navigationTitle("Active Users")
    }
}

extension ChartExtent<ActivityPeriod> {
    fileprivate func segment(from matrices: [ActivityMatrix]) -> [ChartPoint<Int>] {
        segment(from: matrices.points(on: period))
    }
}
