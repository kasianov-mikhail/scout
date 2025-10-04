//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsView: View {
    @ObservedObject var metrics: MetricsProvider
    @State private var model = StatModel(period: Period.month)

    var body: some View {
        VStack(spacing: 0) {
            if let points = model.points(from: metrics.data) {
                List {
                    ChartView(points: points, period: model.period)
                        .foregroundStyle(.blue)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollDisabled(true)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
