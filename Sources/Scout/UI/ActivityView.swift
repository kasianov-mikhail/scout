//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import Charts

struct ActivityView: View {
    @State var model: StatModel<ActivityPeriod>
    @ObservedObject var activity: ActivityProvider

    init(activity: ActivityProvider, period: ActivityPeriod) {
        self.activity = activity
        self._model = State(wrappedValue: StatModel(period: period))
    }

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(model: $model, periods: ActivityPeriod.allCases)

            if let points = model.points(from: activity.data) {
                RangeControl(model: $model)
                    .padding(.top)
                    .padding(.horizontal)

                List {
                    ChartView(points: points, model: model)
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
