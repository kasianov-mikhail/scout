//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricsList: View {
    enum Scope: String, CaseIterable, Identifiable {
        case int
        case double
        case timer

        var id: Self { self }
    }

    @State private var period: Period = .today
    @State private var scope: Scope = .int

    var body: some View {
        Picker("Period", selection: $period) {
            ForEach(Period.all) { period in
                Text(period.shortTitle.uppercased())
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .pickerStyle(.segmented)

        Picker("Scope", selection: $scope) {
            ForEach(Scope.allCases) { scope in
                Text(scope.rawValue.uppercased())
            }
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)

        switch scope {
        case .int:
            MetricsContent(
                period: period,
                formatter: \Int.plain,
                telemetry: .counter
            )
        case .double:
            MetricsContent(
                period: period,
                formatter: \Double.decimal,
                telemetry: .floatingCounter
            )
        case .timer:
            MetricsContent(
                period: period,
                formatter: \TimeInterval.duration,
                telemetry: .timer
            )
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
