//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EventList<Header: View>: View {
    let timeline = Date()

    @Environment(\.database) var database
    @ObservedObject var provider: EventProvider
    var retry: (() async -> Void)? = nil
    @ViewBuilder let header: () -> Header

    var body: some View {
        Group {
            if let events = provider.records {
                if events.isEmpty {
                    Placeholder(
                        text: "No results",
                        systemImage: "list.bullet",
                        description: "Events will appear here once your app starts logging",
                        code: "logger.info(\"button_tapped\")"
                    )
                } else {
                    InsetList {
                        header()
                        rows(for: events)
                    }
                    .animation(nil, value: UUID())
                }
            } else if let error = provider.error {
                ErrorView(description: error.localizedDescription, retry: retryLoad)
            } else {
                RingIndicator().frame(maxHeight: .infinity)
            }
        }
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
        ForEach(events, content: row)

        if let cursor = provider.cursor {
            PaginationFooter {
                await provider.fetchMore(cursor: cursor, in: database)
            }
        }
    }

    func row(for event: Event) -> some View {
        Row {
            HStack(spacing: 12) {
                Text(event.name)
                    .font(.body)
                    .lineLimit(1)
                    .monospaced()

                Spacer()

                if let date = event.date {
                    RelativeTimeText(date: date, timeline: timeline)
                }
            }
        } destination: {
            EventView(event: event)
        }
        .listRowBackground(event.level?.color?.opacity(0.12) ?? .clear)
    }
}

extension EventList where Header == EmptyView {
    init(provider: EventProvider, retry: (() async -> Void)? = nil) {
        self.init(provider: provider, retry: retry) { EmptyView() }
    }
}

#Preview("Empty State") {
    NavigationStack {
        EventList(provider: .init([]))
    }
}
