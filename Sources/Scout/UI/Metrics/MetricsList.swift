//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsList: View {
    @State private var telemetry: Telemetry.Scope = .counter
    @State private var period: Period = .today

    var body: some View {
        Picker("Period", selection: $period) {
            ForEach(Period.all) { period in
                Text(period.shortTitle.uppercased())
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .pickerStyle(.segmented)

        Picker("Metrics Type", selection: $telemetry) {
            ForEach(Telemetry.Scope.allCases) { type in
                Text(type.shortTitle.uppercased())
            }
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)

        switch telemetry {
        case .counter:
            MetricsContent<Int>(period: period, telemetry: telemetry)
        case .floatingCounter:
            MetricsContent<Double>(period: period, telemetry: telemetry)
        case .timer:
            MetricsContent<Double>(period: period, telemetry: telemetry)
        }
    }
}

#Preview("Metrics List") {
    NavigationStack {
        MetricsList()
            .environmentObject(DatabaseController())
            .navigationTitle("Metrics")
    }
}
