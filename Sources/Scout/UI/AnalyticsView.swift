//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

class Tint: ObservableObject {
    @Published var value: Color?
}

public struct AnalyticsView: View {

    @State private var filter = EventQuery()

    @StateObject private var database: DatabaseController
    @StateObject private var provider = EventProvider()
    @StateObject private var search = EventProvider()
    @StateObject private var tint = Tint()

    @Environment(\.dismiss) var dismiss

    init(database: DatabaseController) {
        _database = StateObject(wrappedValue: database)
    }

    public var body: some View {
        NavigationStack {
            Group {
                if !filter.text.isEmpty {
                    EventList(provider: search)
                } else {
                    eventList
                }
            }
            .searchable(text: $filter.text)
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
        }
        .onPreferenceChange(Message.Key.self) { message in
            MainActor.assumeIsolated {
                provider.message = message
            }
        }
        .message($provider.message)
        .environmentObject(database)
        .environmentObject(tint)
        .tint(tint.value)
    }

    var eventList: some View {
        EventList(provider: provider)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    FilterButton(levels: $filter.levels)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .tint(.blue)
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

// MARK: - Initializers

extension AnalyticsView {

    /// Creates a new analytics view. The main entry point for the analytics UI.
    public init(container: CKContainer) {
        self.init(database: DatabaseController(database: container.publicCloudDatabase))
    }

    /// For testing purposes. Do not use in production.
    init() {
        self.init(database: DatabaseController(database: nil))
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
    AnalyticsView()
}
