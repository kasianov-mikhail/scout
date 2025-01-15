//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

class Tint: ObservableObject {
    @Published var value: Color?
}

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
        .message($provider.message)
        .tint(tint.value)
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

// MARK: - Suggestions

extension AnalyticsView {

    /// A view that displays a suggestion based on the provided text.
    struct Suggestion: View {
        let text: String

        var body: some View {
            HStack {
                Text(text)
                    .font(.system(size: 17))
                    .monospaced()
                    .searchCompletion(text)
                    .foregroundStyle(.blue)
                Spacer()
            }
            .alignmentGuide(.listRowSeparatorTrailing) { dimension in
                dimension[.trailing]
            }
        }
    }
}

// MARK: - Unique Array Elements

extension Array {

    /// Returns an array of unique strings from the array, based on a specified key path
    /// and limited to a maximum number of elements.
    ///
    /// - Parameters:
    ///   - path: A key path to the property of the elements to be used for uniqueness.
    ///   - max: The maximum number of unique elements to return.
    /// - Returns: An array of unique strings, sorted by their frequency in descending order.
    ///
    func unique(by path: KeyPath<Element, String>, max: Int) -> [String] {
        let all = reduce(into: [:]) { dict, event in
            dict[event[keyPath: path]] = (dict[event[keyPath: path]] ?? 0) + 1
        }
        .sorted { lhs, rhs in
            lhs.value > rhs.value
        }
        .map(\.key)

        return [String](all.prefix(max))
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
