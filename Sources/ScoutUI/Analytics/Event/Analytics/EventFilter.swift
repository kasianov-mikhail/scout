//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func eventFilter(_ filter: Binding<EventQuery>, provider: EventProvider, search: EventProvider) -> some View {
        modifier(EventFilter(filter: filter, provider: provider, search: search))
    }
}

private struct EventFilter: ViewModifier {
    @Binding var filter: EventQuery
    @ObservedObject var provider: EventProvider
    @ObservedObject var search: EventProvider

    @Environment(\.database) var database

    private var activeProvider: EventProvider {
        filter.text.isEmpty ? provider : search
    }

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            FilterChips(query: $filter)
            content.pullToRefresh {
                await activeProvider.fetch(for: filter, in: database)
            }
        }
        .searchable(text: $filter.text, placement: .pinned, prompt: Text(verbatim: "Search"))
        .autocorrectionDisabled(true)
        .alphabetKeyboard()
        .searchSuggestions {
            if let events = provider.records, filter.text.isEmpty {
                ForEach(events.unique(by: \.name, max: 7), id: \.self) {
                    AnalyticsView.Suggestion(text: $0)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FilterButton(query: $filter)
            }
        }
        .exportToolbar(text: EventListExport(events: activeProvider.records ?? []).text)
        .onSubmit(of: .search) {
            #if os(iOS)
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            #endif
        }
        .task(id: filter) {
            guard !filter.text.isEmpty, (try? await Task.sleep(nanoseconds: 300_000_000)) != nil else {
                return
            }

            search.clear()
            await search.fetch(for: filter, in: database)
        }
        .task(id: filter.criteria) {
            await provider.fetchLatest(for: filter, in: database)
        }
        .onChange(of: filter.criteria) { _ in
            provider.clear()
        }
    }
}

extension SearchFieldPlacement {
    fileprivate static var pinned: SearchFieldPlacement {
        #if os(iOS)
            .navigationBarDrawer(displayMode: .always)
        #else
            .automatic
        #endif
    }
}

extension View {
    fileprivate func alphabetKeyboard() -> some View {
        #if os(iOS)
            keyboardType(.alphabet)
        #else
            self
        #endif
    }
}
