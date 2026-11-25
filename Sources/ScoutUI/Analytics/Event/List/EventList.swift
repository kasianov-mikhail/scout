//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

private let eventScrollSpace = "event-list"

private struct EventRowFramesKey: PreferenceKey {
    static let defaultValue: [Event.ID: CGRect] = [:]

    static func reduce(value: inout [Event.ID: CGRect], nextValue: () -> [Event.ID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct EventList<Header: View>: View {
    @Environment(\.database) var database
    @ObservedObject var provider: EventProvider
    var retry: (() async -> Void)? = nil
    @ViewBuilder let header: () -> Header

    @State private var anchor = EventScrollAnchor()
    @State private var firstID: Event.ID?

    var body: some View {
        ScrollViewReader { scroll in
            content
                .onAppear {
                    firstID = provider.records?.first?.id
                }
                .onChange(of: provider.records?.first?.id) { _ in
                    restoreScroll(with: scroll)
                    firstID = provider.records?.first?.id
                }
                .onChange(of: provider.records == nil) { isNil in
                    if isNil {
                        anchor.reset()
                        firstID = nil
                    }
                }
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
                ScoutUI.Placeholder(
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
                        Placeholder()
                            .transition(.opacity)
                    }
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: eventScrollSpace)
                .onPreferenceChange(EventRowFramesKey.self) { frames in
                    guard provider.records?.first?.id == firstID else {
                        return
                    }
                    anchor.track(frames: frames)
                }
            }
        }
    }

    private func restoreScroll(with scroll: ScrollViewProxy) {
        guard let id = anchor.restoreID(records: provider.records ?? []) else {
            anchor.reset()
            return
        }

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            scroll.scrollTo(id, anchor: .top)
        }
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
        ForEach(events) { event in
            EventRow(event: event)
                .background {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: EventRowFramesKey.self,
                            value: [event.id: proxy.frame(in: .named(eventScrollSpace))]
                        )
                    }
                }
        }

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
