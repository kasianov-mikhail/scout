//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct HangListView: View {
    @Environment(\.database) var database
    @StateObject var provider = IncidentProvider<Hang>()

    var body: some View {
        Group {
            if let groups = provider.groups {
                if groups.isEmpty {
                    Placeholder(
                        text: "No hangs",
                        systemImage: "checkmark.shield",
                        description: "No unresponsive main thread has been recorded"
                    )
                } else {
                    List {
                        ForEach(groups) { group in
                            HangRow(group: group)
                        }

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
        .navigationTitle(en: "Hangs")
        .message($provider.message)
        .autoRefresh {
            await provider.fetchLatest(in: database)
        }
    }
}

#Preview {
    let provider = IncidentProvider<Hang>()
    provider.records = [Hang].samples

    return NavigationStack {
        HangListView(provider: provider)
    }
    .environmentObject(Tint())
}

#Preview("Empty State") {
    NavigationStack {
        Placeholder(
            text: "No hangs",
            systemImage: "checkmark.shield",
            description: "No unresponsive main thread has been recorded"
        )
        .navigationTitle(en: "Hangs")
    }
}
