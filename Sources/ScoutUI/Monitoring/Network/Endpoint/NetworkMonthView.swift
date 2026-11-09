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
        switch provider.result {
        case nil:
            NetworkLedgerPlaceholder(title: title, primary: "DAY")
                .transition(.opacity)
        case .success(let report):
            let rows = report.rows(name: name, range: provider.query.range, component: .day)

            if rows.contains(where: { $0.requests > 0 }) {
                list(report, rows: rows)
                    .transition(.opacity)
            } else {
                Placeholder(
                    text: "No requests",
                    systemImage: "network",
                    description: "No requests have been recorded for this endpoint in this month"
                )
            }
        case .failure(let error):
            ErrorView(description: Text(error.localizedDescription)) {
                await provider.fetchAgain(in: database)
            }
        }
    }

    private var title: String {
        DateFormatter.networkMonthFull.string(from: month)
    }

    private func list(_ report: NetworkReport, rows: [NetworkLedgerRow]) -> some View {
        let endpoint = report.endpoint(name: name, range: provider.query.range) ?? NetworkEndpoint(name: name, requests: 0, successRate: nil, p99: nil)
        let maxRequests = rows.map(\.requests).max() ?? 0

        return InsetList {
            ListTitle(title: title)
                .frame(minHeight: 44)

            NetworkEndpointHeader(endpoint: endpoint, descriptor: "in " + title)
                .frame(minHeight: 44)

            NetworkLedgerHeader(primary: "DAY")
                .frame(minHeight: 44)

            ForEach(rows) { row in
                Row {
                    NetworkLedgerRowView(
                        row: row,
                        maxRequests: maxRequests,
                        label: .monthDay,
                        component: .day,
                        showsDivider: row.id != rows.last?.id
                    )
                } destination: {
                    NetworkDayView(name: name, date: row.date)
                }
            }
        }
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
