//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct EventView: View {
    let event: Event

    @Environment(\.database) var database
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

        InsetList {
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
        .navigationTint(color)
        .monospacedNavigationTitle(en: event.name)
        .navigationDestination(isPresented: $isParamPresented) {
            if let items = try? param.result?.get() {
                ParamList(items: items)
            }
        }
        .task {
            await param.fetchIfNeeded(in: database)
        }
        .periodRefresh(provider: stat)
    }
}

extension EventView {
    struct EventHeader: View {
        let event: Event

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                if let date = event.date {
                    UTCTimestampText(date: date)
                }

                if let level = event.level {
                    (Text(verbatim: "LEVEL:   ") + level.descriptionText).fontWeight(.bold)
                }
            }
            .frame(height: 90)
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

    let param = ParamProvider(recordID: event.id)
    param.result = .success(params.sorted())

    let stat = StatProvider(eventName: event.name, periods: Period.allCases)
    stat.result = .success(.samples)

    return NavigationStack {
        EventView(event: event, param: param, stat: stat)
    }
    .environmentObject(Tint())
}
