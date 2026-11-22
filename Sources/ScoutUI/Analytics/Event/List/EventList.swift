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
    var newEvents: NewEvents? = nil
    var retry: (() async -> Void)? = nil
    @ViewBuilder let header: () -> Header

    var body: some View {
        ScrollViewReader { scroll in
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    if let newEvents {
                        NewEventsRow(counts: newEvents.counts, hasMore: newEvents.hasMore) {
                            Task {
                                if await newEvents.show() {
                                    scroll.scrollTo(ScrollTarget.top, anchor: .top)
                                }
                            }
                        }
                        .transition(.identity)
                    }
                }
                .frame(height: newEvents == nil ? 0 : .rowRegular, alignment: .top)
                .clipped()

                content
            }
            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.36), value: newEvents != nil)
        }
        .animation(.easeOut(duration: 0.2), value: provider.records == nil)
        .loadingInk(isLoading: provider.records == nil)
        .message($provider.message)
    }

    private var content: some View {
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
                            Color.clear.frame(height: 0).id(ScrollTarget.top)
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
    }

    struct NewEvents {
        let counts: [EventLevel: Int]
        let hasMore: Bool
        let show: () async -> Bool
    }

    private enum ScrollTarget: Hashable {
        case top
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
    init(provider: EventProvider, newEvents: NewEvents? = nil, retry: (() async -> Void)? = nil) {
        self.init(provider: provider, newEvents: newEvents, retry: retry) { EmptyView() }
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

#Preview("New Events") {
    NavigationStack {
        EventList(provider: .init(.samples), newEvents: .init(counts: [.critical: 1, .error: 2, .warning: 1, .info: 8], hasMore: false) { true })
            .navigationTitle(en: "Events")
    }
    .environmentObject(Tint())
}
