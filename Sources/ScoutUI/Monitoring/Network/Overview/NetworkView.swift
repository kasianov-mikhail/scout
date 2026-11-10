//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct NetworkView: View {
    @Environment(\.database) private var database

    @State private var range: NetworkRange
    @StateObject var provider: NetworkProvider

    init(_ result: ProviderResult<NetworkReport>? = nil, range: NetworkRange = .today) {
        _range = State(initialValue: range)
        _provider = StateObject(wrappedValue: NetworkProvider(result, query: NetworkQuery(range: range)))
    }

    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: provider.isLoading)
            .navigationTitle(en: "Network")
            .inlineNavigationTitle()
            .task(id: provider.query) {
                await provider.fetchIfNeeded(in: database)
            }
            .onChange(of: range) { newValue in
                provider.result = nil
                provider.query = NetworkQuery(range: newValue)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch provider.result {
        case nil:
            NetworkViewPlaceholder(range: $range)
                .transition(.opacity)
        case .success(let report):
            if report.summary(in: provider.query.range).requests > 0 {
                list(report)
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    RangeStrip(selection: $range, ranges: NetworkRange.allCases, title: \.title)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)

                    Placeholder(
                        text: "No requests",
                        systemImage: "network",
                        description: "No network requests have been recorded in this period"
                    )
                }
            }
        case .failure(let error):
            ErrorView(description: Text(error.localizedDescription)) {
                await provider.fetchAgain(in: database)
            }
        }
    }

    private func list(_ report: NetworkReport) -> some View {
        let endpoints = report.endpoints(in: provider.query.range)
        let summary = report.summary(in: provider.query.range)
        let maxRequests = endpoints.map(\.requests).max() ?? 0

        return InsetList {
            RangeStrip(selection: $range, ranges: NetworkRange.allCases, title: \.title)
                .padding(.top, 8)
                .padding(.trailing, -16)
                .frame(minHeight: 44)

            Text(verbatim: summary.text)
                .font(.weight450(size: 15))
                .foregroundStyle(Color(.systemGray))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                .padding(.bottom, 12)
                .padding(.horizontal, 16)
                .overlay(alignment: .bottom) {
                    Separator()
                }
                .padding(.horizontal, -16)
                .frame(minHeight: 44)

            NetworkEndpointListHeader()
                .frame(minHeight: 44)

            ForEach(endpoints) { endpoint in
                Row {
                    NetworkEndpointRow(endpoint: endpoint, maxRequests: maxRequests)
                } destination: {
                    NetworkEndpointView(name: endpoint.name, initialRange: range)
                }
            }
        }
        .exportToolbar(text: NetworkReportExport(report: report, range: provider.query.range).text)
    }
}

#Preview("Network") {
    NavigationStack {
        NetworkView(.success(.sample(range: .today)))
    }
}

#Preview("Loading") {
    NavigationStack {
        NetworkView()
    }
}

#Preview("Empty") {
    NavigationStack {
        NetworkView(.success(NetworkReport(series: [], bucket: .hour)))
    }
}
