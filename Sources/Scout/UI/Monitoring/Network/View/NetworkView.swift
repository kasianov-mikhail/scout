//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct NetworkView: View {
    @State private var showAllEndpoints = false
    @StateObject var provider = NetworkProvider()

    var body: some View {
        ProviderView(provider: provider) { report in
            if report.isEmpty {
                Placeholder(
                    text: "No requests",
                    systemImage: "network",
                    description: "No network requests have been recorded in this period"
                )
            } else {
                content(report)
            }
        }
        .navigationTitle(en: "Network")
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
                Metric(title: "Req/min", value: report.requestsPerMinute(endpoints, in: range).plain, color: .primary)
                Spacer()
            }
            .listRowSeparator(.hidden)

            Header(title: "Latency P99")
            PercentileTrendChart(trend: report.trend(in: range, component: .hour), unit: .hour)
                .listRowSeparator(.hidden)

            Header(title: "Status codes")
            SegmentBar(segments: breakdown.segments)
                .listRowSeparator(.hidden)

            Header(title: "Top endpoints") {
                AllButton { showAllEndpoints = true }
            }
            ForEach(endpoints.prefix(3)) { endpoint in
                NetworkEndpointLink(endpoint: endpoint, report: report, range: range)
            }
        }
        .listStyle(.plain)
        .navigationDestination(isPresented: $showAllEndpoints) {
            NetworkEndpointsView(report: report, range: range)
        }
        .toolbar {
            if let text = NetworkReportExport(report: report, range: range).text {
                ToolbarItemGroup(placement: .bottomBar) {
                    ShareLink(item: text)
                    CopyButton(text: text)
                    Spacer()
                }
            }
        }
    }
}

#Preview("NetworkView") {
    let provider = NetworkProvider()
    provider.result = .success(.sample)

    return NavigationStack {
        NetworkView(provider: provider)
    }
}

#Preview("Empty State") {
    NavigationStack {
        Placeholder(
            text: "No requests",
            systemImage: "network",
            description: "No network requests have been recorded in this period"
        )
        .navigationTitle(en: "Network")
    }
}
