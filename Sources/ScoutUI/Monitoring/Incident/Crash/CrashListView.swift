//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct CrashListView: View {
    @Environment(\.database) var database
    @StateObject var provider = IncidentProvider<Crash>()

    var body: some View {
        Group {
            if let groups = provider.groups {
                if groups.isEmpty {
                    Placeholder(
                        text: "No crashes",
                        systemImage: "checkmark.shield",
                        description: "No crash reports have been recorded"
                    )
                } else {
                    List {
                        ForEach(groups, content: row)

                        if let cursor = provider.cursor {
                            PaginationFooter {
                                await provider.fetchMore(cursor: cursor, in: database)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .animation(nil, value: groups)
                }
            } else {
                RingIndicator().frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(en: "Crashes")
        .message($provider.message)
        .autoRefresh {
            await provider.fetchLatest(in: database)
        }
    }

    private func row(for group: IncidentGroup<Crash>) -> some View {
        IncidentRow(group: group) { group in
            CrashGroupDetailView(group: group)
        }
    }
}

#Preview {
    let provider = IncidentProvider<Crash>()
    provider.records = .samples

    return NavigationStack {
        CrashListView(provider: provider)
    }
}

#Preview("Empty State") {
    NavigationStack {
        Placeholder(
            text: "No crashes",
            systemImage: "checkmark.shield",
            description: "No crash reports have been recorded"
        )
        .navigationTitle(en: "Crashes")
    }
}
