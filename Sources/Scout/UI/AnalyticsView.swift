//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AnalyticsView: View {

    @State private var filter = EventQuery()

    @StateObject private var provider = EventProvider()
    @StateObject private var search = EventProvider()

    @EnvironmentObject private var database: DatabaseController
    @EnvironmentObject private var tint: Tint

    var body: some View {
        Group {
            if !filter.text.isEmpty {
                EventList(provider: search)
            } else {
                eventList
            }
        }
        .searchable(text: $filter.text, placement: .navigationBarDrawer(displayMode: .always))
        .autocorrectionDisabled(true)  // stop keyboard suggestions
        .keyboardType(.alphabet)  // stop keyboard suggestions
        .searchSuggestions {
            if let events = provider.events, filter.text.isEmpty {
                ForEach(events.unique(by: \.name, max: 7), id: \.self) {
                    Suggestion(text: $0)
                }
            }
        }
        .onSubmit(of: .search) {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )  // hide keyboard on suggestion selected

            Task {
                search.events = nil
                await search.fetch(for: filter, in: database)
            }
        }
        .onChange(of: filter.text) { _ in
            search.events?.removeAll()
        }
        .navigationTitle("Events")
        .onPreferenceChange(Message.Key.self) { message in
            MainActor.assumeIsolated {
                provider.message = message
            }
        }
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
                await fetch()
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

// MARK: - Previews

#Preview {
    NavigationStack {
        AnalyticsView()
            .environmentObject(DatabaseController())
            .environmentObject(Tint())
    }
}
