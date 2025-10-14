//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsContent<T: ChartNumeric>: View {
    let period: Period

    @EnvironmentObject var database: DatabaseController
    @StateObject private var metrics: MetricsProvider<T>

    init(period: Period, telemetry: Telemetry.Scope) {
        self.period = period
        _metrics = StateObject(wrappedValue: MetricsProvider(telemetry: telemetry))
    }

    var body: some View {
        if let matrices = metrics.data {
            let series = MetricsSeries.Compose(of: matrices, period: period)().filter { $0.points.total > .zero }

            if series.isEmpty {
                Placeholder(text: "No results").frame(maxHeight: .infinity)
            } else {
                List(series, rowContent: row).listStyle(.plain)
            }
        } else {
            ProgressView().frame(maxHeight: .infinity).task {
                await metrics.fetchIfNeeded(in: database)
            }
        }
    }

    func row(series: MetricsSeries<T>) -> some View {
        Row {
            Text(series.title)
                .monospaced()
                .font(.system(size: 17))
                .lineLimit(1)
            Spacer()
        } destination: {
            MetricsView(period: period, points: series.points).navigationTitle(series.id)
        }
    }
}
