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
    @StateObject var updates = EventUpdates()

    @Environment(\.database) private var database
    @Environment(\.eventUpdates) private var eventUpdates
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        EventList(provider: activeProvider, updates: updates, retry: retry)
            .eventFilter($filter, provider: provider, search: search)
            .task(id: load) { [load] in
                await observe(load)
            }
            .onChange(of: filter.criteria) { _ in
                provider.clear()
                updates.clear()
            }
            .navigationTitle(en: "Events")
            .inlineNavigationTitle(divider: nil)
            .resetsTint()
    }

    private var activeProvider: EventProvider {
        filter.text.isEmpty ? provider : search
    }

    private var load: Load {
        Load(filter: filter, isPaused: eventUpdates != nil && scenePhase == .background)
    }

    private func observe(_ load: Load) async {
        guard !load.isPaused else {
            return
        }

        if !load.filter.text.isEmpty {
            updates.clear()
            guard (try? await Task.sleep(for: .milliseconds(300))) != nil else {
                return
            }
            search.clear()
            await search.fetch(for: load.filter, in: database)
        } else if let eventUpdates {
            await updates.observe(provider: provider, filter: load.filter, in: database, changes: eventUpdates)
        } else {
            updates.clear()
            await provider.fetchLatest(for: load.filter, in: database)
        }
    }

    private func retry() async {
        if filter.text.isEmpty {
            await updates.reload(provider: provider, filter: filter, in: database)
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
