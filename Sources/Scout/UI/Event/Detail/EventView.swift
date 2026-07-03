//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct EventView: View {
    let event: Event

    @StateObject private var param: ParamProvider
    @State private var isParamPresented = false

    init(event: Event) {
        self.event = event
        _param = StateObject(wrappedValue: ParamProvider(recordID: event.id))
    }

    var body: some View {
        let color = event.level?.color

        List {
            EventHeader(event: event)

            if let paramCount = event.paramCount, paramCount > 0 {
                ParamSection(
                    count: paramCount,
                    param: param,
                    isParamPresented: $isParamPresented
                )
            }

            StatSection(eventName: event.name)
            HistorySection(event: event)
        }
        .listStyle(.plain)
        .navigationTint(color)
        .navigationTitle(event.name)
        .navigationDestination(isPresented: $isParamPresented) {
            if let items = try? param.result?.get() {
                ParamList(items: items)
            }
        }
    }
}

extension EventView {
    struct EventHeader: View {
        let event: Event

        var body: some View {
            VStack(alignment: .leading) {
                if let date = event.date {
                    Text(utcDateFormatter.string(from: date) + " UTC")
                        .font(.system(size: 16))
                        .monospaced()
                }

                Spacer().frame(height: 10)

                if let level = event.level {
                    (Text(verbatim: "LEVEL:   ") + level.descriptionText)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        let event = Event(
            name: "event_name",
            level: .info,
            date: Date(),
            paramCount: 3,
            uuid: UUID(),
            id: UUID().uuidString,
            installID: UUID(),
            sessionID: UUID(),
            deviceID: UUID()
        )
        EventView(event: event)
    }
    .environmentObject(Tint())
}
