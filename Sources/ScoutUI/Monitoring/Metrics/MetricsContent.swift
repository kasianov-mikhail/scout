//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
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
                    code: telemetry.snippet
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
        switch telemetry {
        case .timer:
            MetricsView(group: group, formatter: formatter, period: period) { extent in
                MetricDistributionSection<LatencyHistogram>(
                    name: group.name,
                    categories: LatencyBuckets.categories,
                    extent: extent,
                    formatter: \TimeInterval.duration
                )
            }
        case .recorder:
            MetricsView(group: group, formatter: formatter, period: period) { extent in
                MetricDistributionSection<RecorderHistogram>(
                    name: group.name,
                    categories: RecorderBuckets.categories,
                    extent: extent,
                    formatter: \Double.decimal
                )
            }
        default:
            MetricsView(group: group, formatter: formatter, period: period)
        }
    }

    private func row(group: PointGroup<T>) -> some View {
        HStack {
            Text(group.name)
            Spacer()
            Text(summary(of: group)[keyPath: formatter])
        }
        .monospaced()
        .italic()
        .font(.body)
        .lineLimit(1)
    }

    private func summary(of group: PointGroup<T>) -> T {
        if telemetry == .meter {
            group.points.latest(in: period.initialRange) ?? .zero
        } else {
            group.points.total
        }
    }
}

#Preview("Empty State") {
    NavigationStack {
        Placeholder(
            text: "No results",
            systemImage: "chart.bar",
            description: "Metrics will appear here once your app records data",
            code: Telemetry.Export.timer.snippet
        )
        .navigationTitle(en: "Metrics")
    }
}
