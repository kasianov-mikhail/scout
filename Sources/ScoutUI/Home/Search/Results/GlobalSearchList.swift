//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct GlobalSearchList: View {
    let query: String
    let index: GlobalSearchIndex
    let isLoading: Bool
    let error: Error?
    let retry: () async -> Void

    var body: some View {
        let hits = index.hits(matching: query)

        if !hits.isEmpty {
            InsetList {
                ForEach(hits) { hit in
                    GlobalSearchRow(hit: hit, query: query)
                        .listRowSeparator(hit.id == hits.first?.id ? .hidden : .automatic, edges: .top)
                }

                if let error {
                    ErrorRow(description: error.localizedDescription, retry: retry)
                }

                if isLoading {
                    RingIndicator(size: 22)
                        .frame(height: 68)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden, edges: .bottom)
                }
            }
        } else if isLoading {
            RingIndicator().frame(maxHeight: .infinity)
        } else if let error {
            ErrorView(description: error.localizedDescription, retry: retry)
        } else {
            Placeholder(
                text: "No results",
                systemImage: "magnifyingglass",
                description: "Nothing matches “\(query)”"
            )
        }
    }
}

extension GlobalSearchIndex {
    fileprivate static var sample: GlobalSearchIndex {
        GlobalSearchIndex(
            series: [
                MetricSeries(name: "session_start", category: nil, points: []),
                MetricSeries(name: "session_end", category: nil, points: []),
                MetricSeries(name: "session_duration", category: Telemetry.Export.timer.rawValue, points: []),
                MetricSeries(name: "GET /v1/sessions", category: StatusBuckets.categories[0], points: []),
            ],
            devices: .samples,
            releases: .samples,
            crashes: IncidentGroup.groups(from: .samples).map(IncidentSearchEntry.group),
            hangs: IncidentGroup.groups(from: .samples).map(IncidentSearchEntry.group)
        )
    }
}

#Preview("Loaded") {
    NavigationStack {
        GlobalSearchList(query: "ses", index: .sample, isLoading: false, error: nil) {}
    }
    .environmentObject(Tint())
}

#Preview("Partial") {
    NavigationStack {
        GlobalSearchList(query: "ses", index: .sample, isLoading: true, error: URLError(.timedOut)) {}
    }
    .environmentObject(Tint())
}
