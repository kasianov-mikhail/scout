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
        if let data = metrics.data {
            if data.isEmpty {
                Placeholder(text: "No results").frame(maxHeight: .infinity)
            } else {
                list(series: MetricsSeries.fromMatrices(data))
            }
        } else {
            ProgressView().frame(maxHeight: .infinity).task {
                await metrics.fetchIfNeeded(in: database)
            }
        }
    }

    func list(series: [MetricsSeries<T>]) -> some View {
        List(series) { series in
            Row {
                Text(series.title)
                    .monospaced()
                    .font(.system(size: 17))
                    .lineLimit(1)
                Spacer()
            } destination: {
                MetricsView(period: period, points: series.points)
                    .navigationTitle(series.name)
            }
        }
        .listStyle(.plain)
    }
}
