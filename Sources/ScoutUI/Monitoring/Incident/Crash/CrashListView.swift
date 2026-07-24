//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
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
                    InsetList {
                        ForEach(groups, content: row)

                        if let cursor = provider.cursor {
                            PaginationFooter {
                                await provider.fetchMore(cursor: cursor, in: database)
                            }
                        }
                    }
                    .animation(nil, value: groups)
                }
            } else {
                RingIndicator().frame(maxHeight: .infinity)
            }
        }
        .navigationTitle(en: "Crashes")
        .message($provider.message)
        .periodRefresh(provider: provider)
    }

    private func row(for group: IncidentGroup<Crash>) -> some View {
        IncidentRow(group: group) { group in
            CrashGroupDetailView(group: group)
        }
    }
}

#Preview {
    NavigationStack {
        CrashListView(provider: .init(.samples))
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
