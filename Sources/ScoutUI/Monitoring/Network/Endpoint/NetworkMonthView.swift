//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct NetworkMonthView: View {
    let name: String
    let month: Date

    @Environment(\.database) private var database
    @StateObject var provider: NetworkProvider

    init(name: String, month: Date, result: ProviderResult<NetworkReport>? = nil) {
        self.name = name
        self.month = month
        _provider = StateObject(wrappedValue: NetworkProvider(result, query: NetworkQuery(month: month, name: name)))
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
                description: "No requests have been recorded for this endpoint in this month"
            )
        } else {
            ScrollView {
                if case .success(let report) = provider.result {
                    list(report)
                        .transition(.opacity)
                } else {
                    NetworkLedgerPlaceholder(title: title, primary: "DAY")
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
        let rows = report.rows(name: name, range: provider.query.range, component: .day)
        return !rows.contains { $0.requests > 0 }
    }

    private var title: String {
        DateFormatter.networkMonthFull.string(from: month)
    }

    private func list(_ report: NetworkReport) -> some View {
        let rows = report.rows(name: name, range: provider.query.range, component: .day)
        let endpoint = report.endpoint(name: name, range: provider.query.range) ?? NetworkEndpoint(name: name, requests: 0, successRate: nil, p99: nil)
        let maxRequests = rows.map(\.requests).max() ?? 0

        return LazyVStack(alignment: .leading, spacing: 0) {
            ListTitle(title: title)

            NetworkEndpointHeader(endpoint: endpoint, descriptor: "in " + title)

            NetworkLedgerHeader(primary: "DAY")

            ForEach(rows) { row in
                NavigationLink {
                    NetworkDayView(name: name, date: row.date)
                } label: {
                    NetworkLedgerRowView(
                        row: row,
                        maxRequests: maxRequests,
                        label: .monthDay,
                        component: .day,
                        showsDivider: row.id != rows.last?.id
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, .gutter)
    }
}

#Preview("Month") {
    NavigationStack {
        NetworkMonthView(name: NetworkEndpoint.samples[2].name, month: .now, result: .success(.sample(month: .now)))
    }
}

#Preview("Month loading") {
    NavigationStack {
        NetworkMonthView(name: NetworkEndpoint.samples[2].name, month: .now)
    }
}
