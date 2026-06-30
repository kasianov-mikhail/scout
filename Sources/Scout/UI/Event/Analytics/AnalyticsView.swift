//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AnalyticsView: View {
    @State private var filter = Event.Query()

    @StateObject private var provider = EventProvider()
    @StateObject private var search = EventProvider()

    @Environment(\.database) var database
    @EnvironmentObject private var tint: Tint

    var body: some View {
        Group {
            if !filter.text.isEmpty {
                EventList(provider: search)
            } else {
                eventList
            }
        }
        .searchable(text: $filter.text, placement: .pinned, prompt: Text(verbatim: "Search"))
        .autocorrectionDisabled(true)
        .alphabetKeyboard()
        .searchSuggestions {
            if let events = provider.events, filter.text.isEmpty {
                ForEach(events.unique(by: \.name, max: 7), id: \.self) {
                    Suggestion(text: $0)
                }
            }
        }
        .onSubmit(of: .search) {
            #if os(iOS)
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )  // hide keyboard on suggestion selected
            #endif

            Task {
                search.events = nil
                await search.fetch(for: filter, in: database)
            }
        }
        .onChange(of: filter.text) { _ in
            search.events?.removeAll()
        }
        .navigationTitle(en: "Events")
        .onAppear {
            tint.value = nil
        }
        .message($provider.message)
    }

    var eventList: some View {
        EventList(provider: provider)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    FilterButton(levels: $filter.levels)
                }
            }
            .task {
                await provider.fetchIfNeeded(for: filter, in: database)
            }
            .refreshable {
                await fetch()
            }
            .onChange(of: filter.levels) { _ in
                Task {
                    provider.events = nil
                    await fetch()
                }
            }
    }

    func fetch() async {
        await provider.fetch(for: filter, in: database)
    }
}

private extension SearchFieldPlacement {
    // Always-visible search field: pinned under the navigation bar on iOS, automatic on macOS.
    static var pinned: SearchFieldPlacement {
        #if os(iOS)
            .navigationBarDrawer(displayMode: .always)
        #else
            .automatic
        #endif
    }
}

private extension View {
    // Plain alphabet keyboard on iOS to stop keyboard suggestions; no-op on macOS.
    func alphabetKeyboard() -> some View {
        #if os(iOS)
            keyboardType(.alphabet)
        #else
            self
        #endif
    }
}

#Preview {
    NavigationStack {
        AnalyticsView()
            .environmentObject(Tint())
    }
}
