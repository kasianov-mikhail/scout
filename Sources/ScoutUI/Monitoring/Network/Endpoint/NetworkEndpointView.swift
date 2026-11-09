//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct NetworkEndpointView: View {
    let name: String
    let initialRange: NetworkRange

    @Environment(\.database) private var database

    @State private var range: NetworkRange
    @StateObject var provider: NetworkProvider

    init(name: String, initialRange: NetworkRange, result: ProviderResult<NetworkReport>? = nil) {
        self.name = name
        self.initialRange = initialRange
        _range = State(initialValue: initialRange)
        _provider = StateObject(wrappedValue: NetworkProvider(result, query: NetworkQuery(range: initialRange, name: name, detailed: true)))
    }

    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: provider.isLoading)
            .navigationTitle(en: "Endpoint")
            .inlineNavigationTitle()
            .task(id: provider.query) {
                await provider.fetchIfNeeded(in: database)
            }
            .onChange(of: range) { newValue in
                provider.result = nil
                provider.query = NetworkQuery(range: newValue, name: name, detailed: true)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch provider.result {
        case nil:
            NetworkEndpointViewPlaceholder(range: $range, ranges: ranges)
                .transition(.opacity)
        case .success(let report):
            let rows = report.rows(name: name, range: provider.query.range, component: range.pointComponent)

            if rows.contains(where: { $0.requests > 0 }) {
                list(report, rows: rows)
                    .transition(.opacity)
            } else {
                Placeholder(
                    text: "No requests",
                    systemImage: "network",
                    description: "No requests have been recorded for this endpoint in this period"
                )
            }
        case .failure(let error):
            ErrorView(description: Text(error.localizedDescription)) {
                await provider.fetchAgain(in: database)
            }
        }
    }

    private var ranges: [NetworkRange] {
        NetworkRange.allCases.filter { $0 >= initialRange }
    }

    private func list(_ report: NetworkReport, rows: [NetworkLedgerRow]) -> some View {
        let endpoint = report.endpoint(name: name, range: provider.query.range) ?? NetworkEndpoint(name: name, requests: 0, successRate: nil, p99: nil)
        let maxRequests = rows.map(\.requests).max() ?? 0
        let component = range.pointComponent
        let label: NetworkLedgerLabel =
            switch range {
            case .today, .yesterday:
                .hour
            case .week:
                .weekday
            case .month:
                .monthDay
            case .year:
                .month
            }

        return InsetList {
            RangeStrip(selection: $range, ranges: ranges, title: \.detailTitle)
                .padding(.top, 8)
                .padding(.trailing, -16)
                .frame(minHeight: 44)

            NetworkEndpointHeader(endpoint: endpoint, descriptor: range.descriptor)
                .frame(minHeight: 44)

            NetworkLedgerHeader(primary: component.networkTitle)
                .frame(minHeight: 44)

            ForEach(rows) { row in
                Row {
                    NetworkLedgerRowView(
                        row: row,
                        maxRequests: maxRequests,
                        label: label,
                        component: component,
                        showsDivider: row.id != rows.last?.id
                    )
                } destination: {
                    destination(row, component: component)
                }
            }
        }
    }

    @ViewBuilder
    private func destination(_ row: NetworkLedgerRow, component: Calendar.Component) -> some View {
        switch component {
        case .hour:
            NetworkHourView(name: name, date: row.date)
        case .day:
            NetworkDayView(name: name, date: row.date)
        case .month:
            NetworkMonthView(name: name, month: row.date)
        default:
            EmptyView()
        }
    }
}

#Preview("Endpoint") {
    NavigationStack {
        NetworkEndpointView(name: NetworkEndpoint.samples[2].name, initialRange: .today, result: .success(.sample(range: .today)))
    }
}

#Preview("Endpoint loading") {
    NavigationStack {
        NetworkEndpointView(name: NetworkEndpoint.samples[2].name, initialRange: .today)
    }
}
