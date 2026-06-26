//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct EventList: View {
    let timeline = Date()

    @Environment(\.database) var database
    @ObservedObject var provider: EventProvider

    var body: some View {
        if let events = provider.events {
            if events.isEmpty {
                Placeholder(
                    text: "No results",
                    systemImage: "list.bullet",
                    description: "Events will appear here once your app starts logging",
                    code: "logger.info(\"button_tapped\")"
                )
            } else {
                List {
                    ForEach(events, content: row)

                    if let cursor = provider.cursor {
                        PaginationFooter {
                            await provider.fetchMore(cursor: cursor, in: database)
                        }
                    }
                }
                .listStyle(.plain)
                .animation(nil, value: UUID())
            }
        } else {
            ProgressView().frame(maxHeight: .infinity)
        }
    }

    func row(for event: Event) -> some View {
        Row {
            HStack(spacing: 12) {
                Text(event.name)
                    .font(.system(size: 17))
                    .lineLimit(1)
                    .monospaced()

                Spacer()

                if let date = event.date {
                    TimelineView(.periodic(from: timeline, by: 1)) { _ in
                        Text(verbatim: date.relativeString)
                    }
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gray)
                }
            }
        } destination: {
            EventView(event: event)
        }
        .listRowBackground(event.level?.color?.opacity(0.12) ?? .clear)
    }
}

#Preview("Empty State") {
    let provider = EventProvider()
    provider.events = []
    return NavigationStack {
        EventList(provider: provider)
    }
}
