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
        if let error = provider.error {
            ErrorView(description: Text(error.localizedDescription)) {
                await provider.fetchAgain(in: database)
            }
        } else if isEmpty {
            VStack(spacing: 0) {
                RangeStrip(selection: $range, ranges: ranges, title: \.detailTitle)
                    .padding(.top, .space8)
                    .padding(.horizontal, .gutter)

                Placeholder(
                    text: "No requests",
                    systemImage: "network",
                    description: "No requests have been recorded for this endpoint in this period"
                )
            }
        } else {
            ScrollView {
                if case .success(let report) = provider.result {
                    list(report)
                        .transition(.opacity)
                } else {
                    NetworkEndpointViewPlaceholder(range: $range, ranges: ranges)
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
        let rows = report.rows(name: name, range: provider.query.range, component: range.pointComponent)
        return !rows.contains { $0.requests > 0 }
    }

    private var ranges: [NetworkRange] {
        NetworkRange.allCases.filter { $0 >= initialRange }
    }

    private func list(_ report: NetworkReport) -> some View {
        let rows = report.rows(name: name, range: provider.query.range, component: range.pointComponent)
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

        return LazyVStack(alignment: .leading, spacing: 0) {
            RangeStrip(selection: $range, ranges: ranges, title: \.detailTitle)
                .padding(.top, .space8)
                .padding(.trailing, -16)

            NetworkEndpointHeader(endpoint: endpoint, descriptor: range.descriptor)

            NetworkLedgerHeader(primary: component.networkTitle)

            ForEach(rows) { row in
                NavigationLink {
                    destination(row, component: component)
                } label: {
                    NetworkLedgerRowView(
                        row: row,
                        maxRequests: maxRequests,
                        label: label,
                        component: component,
                        showsDivider: row.id != rows.last?.id
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, .gutter)
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

#Preview("Endpoint empty") {
    NavigationStack {
        NetworkEndpointView(name: NetworkEndpoint.samples[2].name, initialRange: .today, result: .success(NetworkReport(series: [], bucket: .hour)))
    }
}
