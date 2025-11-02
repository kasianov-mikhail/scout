//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

struct EventView: View {
    let event: Event

    @EnvironmentObject var tint: Tint

    var body: some View {
        let color = event.level?.color

        List {
            EventHeader(event: event)

            if let paramCount = event.paramCount, paramCount > 0 {
                ParamSection(
                    count: paramCount,
                    param: ParamProvider(recordID: event.id)
                )
            }

            StatSection(eventName: event.name)
            HistorySection(event: event)
        }
        .onAppear {
            tint.value = color
        }
        .onDisappear {
            tint.value = nil
        }
        .listStyle(.plain)
        .toolbarBackground(color?.opacity(0.12) ?? .clear, for: .navigationBar)
        .toolbarBackground(color == nil ? .automatic : .visible, for: .navigationBar)
        .navigationTitle(event.name)
    }
}

// MARK: - Header

extension EventView {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "dd.MM.y, HH:mm"
        return formatter
    }()

    struct EventHeader: View {
        let event: Event

        var body: some View {
            VStack(alignment: .leading) {
                if let date = event.date {
                    Text(dateFormatter.string(from: date) + " UTC")
                        .font(.system(size: 16))
                        .monospaced()
                }

                Spacer().frame(height: 10)

                if let level = event.level {
                    Group {
                        Text("LEVEL:   ") + level.descriptionText
                    }
                    .fontWeight(.bold)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        let event = Event(
            name: "event_name",
            level: .info,
            date: Date(),
            paramCount: 3,
            uuid: UUID(),
            id: .init(),
            userID: UUID(),
            sessionID: UUID()
        )
        EventView(event: event)
    }
    .environmentObject(Tint())
    .environmentObject(DatabaseController())
}
