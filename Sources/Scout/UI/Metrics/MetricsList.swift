//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsList: View {
    @EnvironmentObject var database: DatabaseController
    @ObservedObject var metrics: MetricsProvider

    var body: some View {
        Group {
            Picker("Metrics Type", selection: $metrics.telemetry) {
                ForEach(Telemetry.Scope.allCases) { type in
                    Text(type.shortTitle.uppercased())
                }
            }
            .onChange(of: metrics.telemetry) { _ in
                Task {
                    await metrics.fetchAgain(in: database)
                }
            }
            .padding(.horizontal)
            .pickerStyle(.segmented)

            if let keys = metrics.keys {
                if keys.isEmpty {
                    Placeholder(text: "No results").frame(maxHeight: .infinity)
                } else {
                    list(keys: keys)
                }
            } else {
                ProgressView().frame(maxHeight: .infinity)
            }
        }
        .navigationTitle("Metrics")
    }

    func list(keys: [String]) -> some View {
        List(keys, id: \.self) { title in
            Row {
                Text(title)
                    .monospaced()
                    .font(.system(size: 17))
                    .lineLimit(1)
                Spacer()
            } destination: {
                MetricsView(metrics: metrics).navigationTitle(title)
            }
        }
        .listStyle(.plain)
    }
}
