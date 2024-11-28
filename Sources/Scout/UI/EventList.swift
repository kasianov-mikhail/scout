//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

struct EventList: View {
    let timeline = Date()

    @ObservedObject var provider: EventProvider
    @Environment(\.eventHistory) var showHistory: Bool
    @EnvironmentObject var database: DatabaseController

    let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    var body: some View {
        if let events = provider.events {
            if events.isEmpty {
                Placeholder(text: "No results").frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(events) { event in
                        row(for: event)
                    }

                    if let cursor = provider.cursor {
                        ProgressView()
                            .task {
                                await provider.fetchMore(cursor: cursor, in: database)
                            }
                            .id(UUID())
                            .frame(height: 72)
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden, edges: .bottom)
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
        ZStack {
            HStack(spacing: 12) {
                Text(event.name)
                    .font(.system(size: 17))
                    .lineLimit(1)
                    .monospaced()

                Spacer()

                if let date = event.date {
                    TimelineView(.periodic(from: timeline, by: 1)) { _ in
                        if date.timeIntervalSinceNow < -60 {
                            Text(dateFormatter.localizedString(for: date, relativeTo: Date()))
                        } else {
                            Text("recently")
                        }
                    }
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gray)
                }
            }

            NavigationLink {
                EventView(event: event, showHistory: true)
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
        .listRowBackground(event.level?.color?.opacity(0.12) ?? .clear)
        .alignmentGuide(.listRowSeparatorTrailing) { dimension in
            dimension[.trailing]
        }
    }
}
