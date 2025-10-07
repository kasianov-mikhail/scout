// wrap both previews into a VStack to avoid truncation
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct MetricsView<T: ChartNumeric>: View {
    let period: Period
    let points: [ChartPoint<T>]

    var body: some View {
        List {
            ChartView(points: points, period: period)
                .foregroundStyle(.blue)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollDisabled(true)
    }
}

#Preview("MetricsView") {
    VStack(alignment: .leading, spacing: 24) {
        Text("With Data").font(.headline)
        MetricsView(period: .month, points: .sample)

        Text("Empty State").font(.headline)
        MetricsView(period: .month, points: .empty)
    }
    .padding()
}
