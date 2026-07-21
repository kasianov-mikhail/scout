//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct MetricSearchDetail: View {
    let name: String
    let telemetry: Telemetry.Export

    var body: some View {
        switch telemetry {
        case .floatingCounter, .recorder, .meter:
            MetricSearchContent(name: name, telemetry: telemetry, formatter: \Double.decimal)
        case .timer:
            MetricSearchContent(name: name, telemetry: telemetry, formatter: \TimeInterval.duration)
        default:
            MetricSearchContent(name: name, telemetry: telemetry, formatter: \Int.plain)
        }
    }
}

private struct MetricSearchContent<T: ChartNumeric>: View {
    let name: String
    let telemetry: Telemetry.Export
    let formatter: KeyPath<T, String>

    @StateObject var provider: MetricsProvider<T>

    init(name: String, telemetry: Telemetry.Export, formatter: KeyPath<T, String>) {
        self.name = name
        self.telemetry = telemetry
        self.formatter = formatter
        self._provider = StateObject(wrappedValue: MetricsProvider(telemetry: telemetry))
    }

    var body: some View {
        ProviderView(provider: provider) { data in
            let groups: [PointGroup<T>] = data.pointGroups()

            if let group = groups.named(name) {
                switch telemetry {
                case .timer:
                    MetricsView(group: group, formatter: formatter, period: .today) { extent in
                        MetricDistributionSection<LatencyHistogram>(
                            name: group.name,
                            categories: LatencyBuckets.categories,
                            extent: extent,
                            formatter: \TimeInterval.duration
                        )
                    }
                case .recorder:
                    MetricsView(group: group, formatter: formatter, period: .today) { extent in
                        MetricDistributionSection<RecorderHistogram>(
                            name: group.name,
                            categories: RecorderBuckets.categories,
                            extent: extent,
                            formatter: \Double.decimal
                        )
                    }
                default:
                    MetricsView(
                        group: group, formatter: formatter, period: .today, tracksResets: telemetry.hasResets)
                }
            } else {
                Placeholder(
                    text: "No data",
                    systemImage: "chart.bar",
                    description: "No values have been recorded for this metric in the current period"
                )
            }
        }
    }
}
