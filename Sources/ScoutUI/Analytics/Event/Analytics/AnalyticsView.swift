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
    @StateObject private var eventUpdates = EventUpdates()
    @StateObject private var searchUpdates = EventUpdates()

    @Environment(\.database) private var database
    @Environment(\.eventChanges) private var eventChanges
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        EventList(provider: activeProvider, newEvents: newEvents, retry: retry)
            .eventFilter($filter, provider: provider, search: search)
            .task(id: load) { [load] in
                await observe(load)
            }
            .onChange(of: filter.criteria) { _ in
                provider.clear()
                eventUpdates.clear()
            }
            .navigationTitle(en: "Events")
            .inlineNavigationTitle()
            .resetsTint()
    }

    private var activeProvider: EventProvider {
        filter.text.isEmpty ? provider : search
    }

    private var activeUpdates: EventUpdates {
        filter.text.isEmpty ? eventUpdates : searchUpdates
    }

    private var newEvents: EventList<EmptyView>.NewEvents? {
        let provider = activeProvider
        let updates = activeUpdates
        return updates.newEvents.map { summary in
            EventList.NewEvents(counts: summary.counts, hasMore: summary.hasMore) {
                await updates.showNewEvents(updating: provider, in: database)
            }
        }
    }

    private var load: Load {
        Load(filter: filter, isPaused: eventChanges != nil && scenePhase != .active)
    }

    private func observe(_ load: Load) async {
        guard !load.isPaused else {
            return
        }

        let isSearching = !load.filter.text.isEmpty
        let provider = isSearching ? search : provider
        let updates = isSearching ? searchUpdates : eventUpdates
        if isSearching {
            guard (try? await Task.sleep(for: .milliseconds(300))) != nil else {
                return
            }
            provider.clear()
            updates.clear()
        }
        if let eventChanges {
            await updates.observe(for: load.filter, updating: provider, in: database, changes: eventChanges)
        } else if isSearching {
            await provider.fetch(for: load.filter, in: database)
        } else {
            await provider.fetchLatest(for: load.filter, in: database)
        }
    }

    private func retry() async {
        if filter.text.isEmpty {
            await provider.fetchLatest(for: filter, in: database)
        } else {
            await search.fetch(for: filter, in: database)
        }
    }

    private struct Load: Equatable {
        let filter: EventQuery
        let isPaused: Bool
    }
}

#Preview {
    NavigationStack {
        AnalyticsView(provider: .init(.samples))
            .environmentObject(Tint())
    }
}
