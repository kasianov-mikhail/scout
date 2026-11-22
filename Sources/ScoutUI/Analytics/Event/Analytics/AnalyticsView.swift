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
    @Environment(\.eventChanges) private var eventChanges
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        EventList(provider: activeProvider, retry: retry) { EmptyView() }
            .eventFilter($filter, provider: provider, search: search)
            .task(id: load) { [load] in
                await observe(load)
            }
            .onChange(of: filter.criteria) { _ in
                provider.clear()
            }
            .navigationTitle(en: "Events")
            .inlineNavigationTitle()
            .resetsTint()
    }

    private var activeProvider: EventProvider {
        filter.text.isEmpty ? provider : search
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
        if isSearching {
            guard (try? await Task.sleep(for: .milliseconds(300))) != nil else {
                return
            }
            provider.clear()
        }
        if let eventChanges {
            await provider.observe(for: load.filter, in: database, changes: eventChanges)
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
