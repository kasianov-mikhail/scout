//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct EventView: View {
    let event: Event

    @StateObject var param: ParamProvider
    @StateObject var stat: StatProvider
    @State private var isParamPresented = false

    init(event: Event, param: ParamProvider? = nil, stat: StatProvider? = nil) {
        self.event = event
        _param = StateObject(wrappedValue: param ?? ParamProvider(recordID: event.id))
        _stat = StateObject(wrappedValue: stat ?? StatProvider(eventName: event.name, periods: Period.allCases))
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

            StatSection(stat: stat)
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
                    UTCTimestampText(date: date)
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
    let params = ParamProvider.Item.samplePurchase
    let event = Event(
        name: "event_name",
        level: .info,
        date: Date(),
        paramCount: params.count,
        uuid: UUID(),
        id: UUID().uuidString,
        installID: UUID(),
        sessionID: UUID(),
        deviceID: UUID()
    )

    NavigationStack {
        EventView(
            event: event,
            param: .fixture(items: params),
            stat: .fixture(eventName: event.name)
        )
    }
    .environmentObject(Tint())
}
