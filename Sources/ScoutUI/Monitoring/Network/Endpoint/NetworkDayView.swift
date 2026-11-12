//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct NetworkDayView: View {
    let name: String
    let date: Date

    @Environment(\.database) private var database
    @StateObject var provider: NetworkProvider

    init(name: String, date: Date, result: ProviderResult<NetworkReport>? = nil) {
        self.name = name
        self.date = date
        _provider = StateObject(wrappedValue: NetworkProvider(result, query: NetworkQuery(day: date, name: name)))
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
            NetworkLedgerPlaceholder(title: title, primary: "HOUR")
                .transition(.opacity)
        case .success(let report):
            let rows = report.rows(name: name, range: provider.query.range, component: .hour)

            if rows.contains(where: { $0.requests > 0 }) {
                list(report, rows: rows)
                    .transition(.opacity)
            } else {
                Placeholder(
                    text: "No requests",
                    systemImage: "network",
                    description: "No requests have been recorded for this endpoint on this day"
                )
            }
        case .failure(let error):
            ErrorView(description: Text(error.localizedDescription)) {
                await provider.fetchAgain(in: database)
            }
        }
    }

    private var title: String {
        DateFormatter.networkDayLabel.string(from: date)
    }

    private func list(_ report: NetworkReport, rows: [NetworkLedgerRow]) -> some View {
        let endpoint = report.endpoint(name: name, range: provider.query.range) ?? NetworkEndpoint(name: name, requests: 0, successRate: nil, p99: nil)
        let maxRequests = rows.map(\.requests).max() ?? 0

        return ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ListTitle(title: title)

                NetworkEndpointHeader(endpoint: endpoint, descriptor: "on " + DateFormatter.networkDayFull.string(from: date))

                NetworkLedgerHeader(primary: "HOUR")

                ForEach(rows) { row in
                    NavigationLink {
                        NetworkHourView(name: name, date: row.date)
                    } label: {
                        NetworkLedgerRowView(
                            row: row,
                            maxRequests: maxRequests,
                            label: .hour,
                            component: .hour,
                            showsDivider: row.id != rows.last?.id
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }
}

#Preview("Day") {
    NavigationStack {
        NetworkDayView(name: NetworkEndpoint.samples[2].name, date: .now, result: .success(.sample(day: .now)))
    }
}

#Preview("Day loading") {
    NavigationStack {
        NetworkDayView(name: NetworkEndpoint.samples[2].name, date: .now)
    }
}
