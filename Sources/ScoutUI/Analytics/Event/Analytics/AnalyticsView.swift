//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AnalyticsView: View {
    @State private var filter = EventQuery()

    @StateObject var provider = EventProvider()
    @StateObject var search = EventProvider()

    @Environment(\.database) private var database

    var body: some View {
        EventList(
            provider: activeProvider,
            retry: retry,
            newEvents: EventPendingSummary(counts: activeProvider.newCounts, limit: 4),
            showPending: {
                Task {
                    await activeProvider.refresh(in: database)
                }
            }
        ) {
            EmptyView()
        }
        .eventFilter($filter, provider: provider, search: search)
        .fetchTask([activeProvider])
        .navigationTitle(en: "Events")
        .inlineNavigationTitle()
        .resetsTint()
    }

    private var activeProvider: EventProvider {
        filter.text.isEmpty ? provider : search
    }

    private func retry() async {
        if filter.text.isEmpty {
            await provider.fetchLatest(for: filter, in: database)
        } else {
            await search.fetch(for: filter, in: database)
        }
    }
}

#Preview {
    NavigationStack {
        AnalyticsView(provider: .init(.samples))
            .environmentObject(Tint())
    }
}
