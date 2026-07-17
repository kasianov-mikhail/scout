//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct MetricsContent<T: ChartNumeric>: View {
    let period: Period
    let formatter: KeyPath<T, String>
    let telemetry: Telemetry.Export

    @StateObject var provider: MetricsProvider<T>

    init(period: Period, formatter: KeyPath<T, String>, telemetry: Telemetry.Export) {
        self.period = period
        self.formatter = formatter
        self.telemetry = telemetry
        self._provider = StateObject(wrappedValue: MetricsProvider(telemetry: telemetry))
    }

    var body: some View {
        ProviderView(provider: provider) { data in
            let groups: [PointGroup<T>] = data.pointGroups()
            let ranked = groups.ranked(on: period)

            if ranked.isEmpty {
                Placeholder(
                    text: "No results",
                    systemImage: "chart.bar",
                    description: "Metrics will appear here once your app records data",
                    code: "Counter(label: \"api_calls\").increment()"
                )
            } else {
                List(ranked) { group in
                    Row {
                        row(group: group)
                    } destination: {
                        if let named = groups.named(group.name) {
                            destination(group: named)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func destination(group: PointGroup<T>) -> some View {
        if telemetry == .timer {
            MetricsView(group: group, formatter: formatter, period: period) { extent in
                TimerDistributionSection(name: group.name, extent: extent)
            }
        } else {
            MetricsView(group: group, formatter: formatter, period: period)
        }
    }

    private func row(group: PointGroup<T>) -> some View {
        HStack {
            Text(group.name)
            Spacer()
            Text(group.points.total[keyPath: formatter])
        }
        .monospaced()
        .italic()
        .font(.body)
        .lineLimit(1)
    }
}

#Preview("Empty State") {
    NavigationStack {
        Placeholder(
            text: "No results",
            systemImage: "chart.bar",
            description: "Metrics will appear here once your app records data",
            code: "Counter(label: \"api_calls\").increment()"
        )
        .navigationTitle(en: "Metrics")
    }
}
