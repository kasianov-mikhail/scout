//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct NetworkView: View {
    @Environment(\.database) var database
    @StateObject private var provider: NetworkProvider

    init(provider: NetworkProvider = NetworkProvider()) {
        self._provider = StateObject(wrappedValue: provider)
    }

    var body: some View {
        ProviderView(provider: provider) { report in
            if report.isEmpty {
                Text(verbatim: "No network requests in this period.")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                content(report)
            }
        }
        .navigationTitle(en: "Network")
        .task {
            await provider.fetchIfNeeded(in: database)
        }
    }

    private func content(_ report: NetworkReport) -> some View {
        let range = Period.today.initialRange
        let endpoints = report.endpoints(in: range)
        let breakdown = report.summary(in: range)
        let successRate = breakdown.total > 0 ? breakdown.successRate : nil

        return List {
            HStack(spacing: 28) {
                Metric(title: "P99", value: report.percentiles(in: range)?.p99.duration ?? "—", color: .orange)
                Metric(title: "Success", value: successRate?.formatted ?? "—", color: successRate?.color ?? .primary)
                Metric(title: "Req/min", value: report.requestsPerMinute(in: range).plain, color: .primary)
                Spacer()
            }
            .listRowSeparator(.hidden)

            Header(title: "Latency P99")
            PercentileTrendChart(trend: report.trend(in: range, component: .hour), unit: .hour)
                .listRowSeparator(.hidden)

            Header(title: "Status codes")
            StatusBar(status: breakdown)
                .listRowSeparator(.hidden)

            Header(title: "Top endpoints") {
                NavigationLink {
                    NetworkEndpointsView(report: report, range: range)
                } label: {
                    Text(verbatim: "See all").foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            ForEach(endpoints.prefix(3)) { endpoint in
                NetworkEndpointLink(endpoint: endpoint, report: report, range: range)
            }
        }
        .listStyle(.plain)
    }
}

#Preview("NetworkView") {
    NavigationStack {
        NetworkView(provider: .fixture())
    }
}
