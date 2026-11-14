//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct NetworkHourView: View {
    let name: String
    let date: Date

    @Environment(\.database) private var database
    @StateObject var provider: NetworkProvider

    init(name: String, date: Date, result: ProviderResult<NetworkReport>? = nil) {
        self.name = name
        self.date = date
        _provider = StateObject(wrappedValue: NetworkProvider(result, query: NetworkQuery(hour: date, name: name)))
    }

    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: provider.isLoading)
            .navigationTitle(en: "Endpoint")
            .inlineNavigationTitle()
            .task(id: provider.query) {
                await provider.fetchIfNeeded(in: database)
            }
    }

    @ViewBuilder
    private var content: some View {
        if let error = provider.error {
            ErrorView(description: Text(error.localizedDescription)) {
                await provider.fetchAgain(in: database)
            }
        } else if isEmpty {
            Placeholder(
                text: "No requests",
                systemImage: "network",
                description: "No requests have been recorded for this endpoint at this hour"
            )
        } else {
            ScrollView {
                if case .success(let report) = provider.result {
                    list(report)
                        .transition(.opacity)
                } else {
                    NetworkHourViewPlaceholder(date: date)
                        .transition(.opacity)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var isEmpty: Bool {
        guard case .success(let report) = provider.result else {
            return false
        }
        let requests = report.endpoint(name: name, range: provider.query.range)?.requests ?? 0
        return requests == 0 && report.percentiles(name: name, range: provider.query.range) == nil
    }

    private func list(_ report: NetworkReport) -> some View {
        let range = provider.query.range
        let endpoint = report.endpoint(name: name, range: range) ?? NetworkEndpoint(name: name, requests: 0, successRate: nil, p99: nil)
        let breakdown = report.statusBreakdown(name: name, range: range)

        return LazyVStack(alignment: .leading, spacing: 0) {
            ListTitle(title: DateFormatter.networkHourLabel.string(from: date))

            NetworkEndpointHeader(endpoint: endpoint, descriptor: "on " + DateFormatter.networkDayFull.string(from: date))

            if breakdown.total > 0 {
                SectionHeader(title: "STATUS")

                ProportionBar(
                    items: breakdown.networkClasses,
                    color: { _, item in item.color },
                    share: { breakdown.total > 0 ? Double($0.count) / Double(breakdown.total) : 0 }
                )
                .padding(.top, .space12)
                .padding(.bottom, .space6)

                ForEach(breakdown.networkClasses) { item in
                    NetworkStatusRow(item: item, total: breakdown.total)
                }
            }

            if let histogram = report.histogram(name: name, range: range), histogram.total > 0 {
                SectionHeader(title: "LATENCY")

                NetworkLatencyChart(histogram: histogram)

                NetworkPercentileRow(percentiles: report.percentiles(name: name, range: range))
            }
        }
        .padding(.horizontal, .gutter)
    }
}

#Preview("Hour") {
    NavigationStack {
        NetworkHourView(name: NetworkEndpoint.samples[2].name, date: .now, result: .success(.sample(hour: .now)))
    }
}

#Preview("Hour loading") {
    NavigationStack {
        NetworkHourView(name: NetworkEndpoint.samples[2].name, date: .now)
    }
}
