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

    var body: some View {
        let hits = index.hits(matching: query)

        if hits.count > 0 {
            PlainList {
                ForEach(hits) { hit in
                    GlobalSearchRow(hit: hit, query: query)
                        .listRowSeparator(hit.id == hits.first?.id ? .hidden : .automatic, edges: .top)
                }
            }
        } else {
            Placeholder(
                text: "No results",
                systemImage: "magnifyingglass",
                description: "Nothing matches “\(query)”"
            )
        }
    }
}

#Preview {
    let index = GlobalSearchIndex(
        series: [
            MetricSeries(name: "session_start", category: nil, points: []),
            MetricSeries(name: "session_end", category: nil, points: []),
            MetricSeries(name: "session_duration", category: Telemetry.Export.timer.rawValue, points: []),
            MetricSeries(name: "GET /v1/sessions", category: StatusBuckets.categories[0], points: []),
        ],
        devices: .samples,
        releases: .samples,
        crashes: IncidentGroup.groups(from: .samples),
        hangs: IncidentGroup.groups(from: .samples)
    )

    return NavigationStack {
        if let index {
            GlobalSearchList(query: "ses", index: index)
        }
    }
    .environmentObject(Tint())
}
