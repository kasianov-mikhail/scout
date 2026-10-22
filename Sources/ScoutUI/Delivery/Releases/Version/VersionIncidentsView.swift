//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct VersionIncidentsView<Element: RecordDecodable & Incident, Destination: View>: View {
    let issuesTitle: String
    let days: [DailyCount]

    @Environment(\.database) var database
    @StateObject var provider: VersionIncidentProvider<Element>

    @ViewBuilder let destination: (IncidentGroup<Element>) -> Destination

    var body: some View {
        InsetList {
            IncidentTrendChart(kind: Element.kind, days: days)
                .padding(.top)

            if let records = provider.records {
                IncidentIssuesSection(
                    title: issuesTitle,
                    groups: IncidentGroup.groups(from: records, hasMore: provider.cursor != nil),
                    destination: destination
                )

                if let cursor = provider.cursor {
                    PaginationFooter {
                        await provider.fetchMore(cursor: cursor, in: database)
                    }
                }
            } else if let error = provider.error {
                ErrorRow(description: error.localizedDescription) {
                    await provider.fetchAgain(in: database)
                }
            } else {
                RingIndicator()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .listRowSeparator(.hidden)
            }
        }
        .navigationTitle(en: Element.kind.title)
        .largeNavigationTitle()
        .message($provider.message)
        .refreshes([provider])
    }
}

private struct IncidentIssuesSection<Element: Incident, Destination: View>: View {
    let title: String
    let groups: [IncidentGroup<Element>]
    @ViewBuilder let destination: (IncidentGroup<Element>) -> Destination

    @ViewBuilder
    var body: some View {
        if !groups.isEmpty {
            Header(title: title)

            ForEach(groups) { group in
                Row {
                    Text(verbatim: group.name)
                        .font(.callout)
                        .monospaced()
                        .lineLimit(1)

                    Spacer()

                    CountBadge(
                        count: group.count,
                        suffix: group.countSuffix,
                        color: Element.kind.color
                    )
                } destination: {
                    destination(group)
                }
            }
        }
    }
}

#Preview("Issues") {
    NavigationStack {
        VersionIncidentsView(
            issuesTitle: "Top crash issues",
            days: VersionTrend.sample.crashes,
            provider: VersionIncidentProvider<Crash>(.samples, version: "3.2.0")
        ) { group in
            CrashGroupDetailView(group: group)
        }
    }
    .environmentObject(Tint())
}
