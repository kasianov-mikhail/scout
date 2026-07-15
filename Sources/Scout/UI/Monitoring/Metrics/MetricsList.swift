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

        var telemetry: Telemetry.Export {
            switch self {
            case .int:
                .counter
            case .double:
                .floatingCounter
            case .timer:
                .timer
            }
        }
    }

    @State private var period: Period = .today
    @State private var scope: Scope = .int

    var body: some View {
        SegmentStrip(selection: $period, distribution: .justified, title: \.shortTitle)
            .padding()

        SegmentStrip(selection: $scope, distribution: .justified, title: \.rawValue)
            .padding(.horizontal)

        switch scope {
        case .int:
            MetricsContent(
                period: period,
                formatter: \Int.plain,
                telemetry: scope.telemetry
            )
        case .double:
            MetricsContent(
                period: period,
                formatter: \Double.decimal,
                telemetry: scope.telemetry
            )
        case .timer:
            MetricsContent(
                period: period,
                formatter: \TimeInterval.duration,
                telemetry: scope.telemetry
            )
        }
    }
}

#Preview("Metrics List") {
    NavigationStack {
        MetricsList().navigationTitle(en: "Metrics")
    }
}
