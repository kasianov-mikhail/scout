//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EventList<Header: View>: View {
    @Environment(\.database) var database
    @ObservedObject var provider: EventProvider
    var retry: (() async -> Void)? = nil
    @ViewBuilder let header: () -> Header

    var body: some View {
        Group {
            if let error = provider.error {
                ErrorView(description: error.localizedDescription, retry: retryLoad)
            } else if let events = provider.records, events.isEmpty {
                Placeholder(
                    text: "No results",
                    systemImage: "list.bullet",
                    description: "Events will appear here once your app starts logging",
                    code: "logger.info(\"button_tapped\")"
                )
            } else {
                ScrollView {
                    if let events = provider.records {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            header()
                            rows(for: events)
                        }
                        .padding(.horizontal, .gutter)
                        .animation(nil, value: UUID())
                        .transition(.opacity)
                    } else {
                        EventListPlaceholder()
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.records == nil)
        .message($provider.message)
    }

    private func retryLoad() async {
        if let retry {
            await retry()
        } else {
            await provider.fetchAgain(in: database)
        }
    }

    @ViewBuilder
    private func rows(for events: [Event]) -> some View {
        ForEach(events, content: EventRow.init)

        if let cursor = provider.cursor {
            PaginationFooter {
                await provider.fetchMore(cursor: cursor, in: database)
            }
        }
    }
}

extension EventList where Header == EmptyView {
    init(provider: EventProvider, retry: (() async -> Void)? = nil) {
        self.init(provider: provider, retry: retry) { EmptyView() }
    }
}

#Preview("Rows") {
    NavigationStack {
        EventList(provider: .init(.samples))
            .navigationTitle(en: "Events")
    }
    .environmentObject(Tint())
}

#Preview("Loading") {
    NavigationStack {
        EventList(provider: .init())
            .navigationTitle(en: "Events")
    }
    .environmentObject(Tint())
}

#Preview("Empty State") {
    NavigationStack {
        EventList(provider: .init([]))
    }
}
