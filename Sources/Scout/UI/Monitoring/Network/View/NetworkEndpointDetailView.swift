//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct NetworkEndpointDetailView: View {
    let endpoint: NetworkEndpoint
    let distribution: TimerDistribution?
    let statuses: StatusDistribution?
    let range: Range<Date>
    var unit: Calendar.Component = .hour

    init(endpoint: NetworkEndpoint, report: NetworkReport, range: Range<Date>, unit: Calendar.Component = .hour) {
        self.endpoint = endpoint
        self.distribution = report.distributions[endpoint.name]
        self.statuses = report.statuses[endpoint.name]
        self.range = range
        self.unit = unit
    }

    var body: some View {
        List {
            HStack(spacing: 28) {
                Metric(title: "Method", value: endpoint.method ?? "—", color: endpoint.methodColor)
                Metric(title: "Requests", value: endpoint.requests.plain, color: .primary)
                Metric(title: "Success", value: endpoint.successRate?.formatted ?? "—", color: endpoint.successRate?.color ?? .gray)
                Spacer()
            }
            .listRowSeparator(.hidden)

            if let percentiles = distribution?.summary(in: range) {
                Header(title: "Latency")
                PercentileRow(percentiles: percentiles)
                    .listRowSeparator(.hidden, edges: .bottom)
            }

            if let trend = distribution?.trend(in: range, component: unit), trend.count > 0 {
                Header(title: "P99 trend")
                PercentileTrendChart(trend: trend, unit: unit)
                    .listRowSeparator(.hidden)
            }

            if let breakdown = statuses?.summary(in: range), breakdown.total > 0 {
                Header(title: "Status codes")
                SegmentBar(segments: breakdown.segments)
                    .listRowSeparator(.hidden, edges: .bottom)
            }
        }
        .listStyle(.plain)
        .monospacedNavigationTitle(en: endpoint.path)
    }
}

#Preview("NetworkEndpointDetailView") {
    let report = NetworkReport.sample
    let range = Period.today.initialRange
    let endpoint = report.endpoints(in: range)[2]

    NavigationStack {
        NetworkEndpointDetailView(endpoint: endpoint, report: report, range: range)
    }
}
