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
        EventList(provider: activeProvider, retry: retry)
            .eventFilter($filter, provider: provider, search: search)
            .autoRefresh(id: filter) {
                await refresh()
            }
            .onChange(of: filter.criteria) { _ in
                provider.clear()
            }
            .navigationTitle(en: "Events")
            .inlineNavigationTitle(divider: nil)
            .resetsTint()
    }

    private var activeProvider: EventProvider {
        filter.text.isEmpty ? provider : search
    }

    private func refresh() async {
        if filter.text.isEmpty {
            await provider.fetchLatest(for: filter, in: database)
        } else {
            if search.filter != filter {
                search.clear()
                guard (try? await Task.sleep(for: .milliseconds(300))) != nil else {
                    return
                }
            }
            await search.fetch(for: filter, in: database)
        }
    }

    private func retry() async {
        await refresh()
    }
}

#Preview {
    NavigationStack {
        AnalyticsView(provider: .init(.samples))
            .environmentObject(Tint())
    }
}
