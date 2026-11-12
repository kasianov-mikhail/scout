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

    @Environment(\.database) private var database
    @StateObject var param: ParamProvider
    @StateObject var stat: StatProvider
    @StateObject var context: EventContextProvider
    @State private var isParamPresented = false

    init(event: Event, param: ParamProvider? = nil, stat: StatProvider? = nil, context: EventContextProvider? = nil) {
        self.event = event
        self._param = StateObject(wrappedValue: param ?? ParamProvider(recordID: event.id))
        self._stat = StateObject(wrappedValue: stat ?? StatProvider(subject: .event(event.name)))
        self._context = StateObject(
            wrappedValue: context ?? EventContextProvider(sessionID: event.sessionID ?? UUID(), deviceID: event.deviceID)
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                EventHeader(event: event)

                if let sessionID = event.sessionID {
                    ContextSection(sessionID: sessionID, deviceID: event.deviceID, context: context)
                }

                if let paramCount = event.paramCount, paramCount > 0 {
                    ParamSection(
                        count: paramCount,
                        param: param,
                        isParamPresented: $isParamPresented
                    )
                }

                StatSection(stat: stat)
                TimelineSection(event: event)
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
        .animation(.easeOut(duration: 0.2), value: [param.isLoading, stat.isLoading, context.isLoading])
        .navigationTint(event.level?.color)
        .monospacedNavigationTitle(en: event.name)
        .navigationDestination(isPresented: $isParamPresented) {
            switch param.result {
            case .success(let items):
                ParamList(items: items)
            case .failure(let error):
                ErrorView(description: error.localizedDescription) {
                    await param.fetchAgain(in: database)
                }
            case nil:
                RingIndicator().frame(maxHeight: .infinity)
            }
        }
        .fetchTask(providers)
    }

    private var providers: [any Refreshable] {
        event.sessionID == nil ? [stat, param] : [stat, param, context]
    }
}

extension EventView {
    struct EventHeader: View {
        let event: Event

        var body: some View {
            HStack(spacing: 10) {
                if let level = event.level {
                    Text(verbatim: level.description.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.3)
                        .foregroundStyle(level.badgeInk)
                        .badgeStyle(fill: level.badgeFill)
                }

                if let date = event.date {
                    Text(verbatim: eventDateFormatter.string(from: date) + " UTC")
                        .font(.book(size: 15))
                        .monospacedDigit()
                        .foregroundStyle(Color.eventTimestamp)
                }
            }
            .padding(.top, 18)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                Separator()
            }
        }
    }
}

private let eventDateFormatter = DateFormatter(format: "d MMM y, HH:mm")

#Preview {
    let params = ParamProvider.Item.samplePurchase
    let event = Event(
        name: "IPRecordFailed",
        level: .warning,
        date: Date(),
        paramCount: params.count,
        uuid: UUID(),
        id: UUID().uuidString,
        installID: UUID(),
        sessionID: UUID(),
        deviceID: UUID()
    )

    let param = ParamProvider(.success(params.sorted()), recordID: event.id)
    let stat = StatProvider(.success(.samples), subject: .event(event.name))
    let context = EventContextProvider(.success(.sample), sessionID: UUID(), deviceID: UUID())

    return NavigationStack {
        EventView(event: event, param: param, stat: stat, context: context)
    }
    .environmentObject(Tint())
}

#Preview("Loading") {
    let event = Event(
        name: "IPRecordFailed",
        level: .warning,
        date: Date(),
        paramCount: 3,
        uuid: UUID(),
        id: UUID().uuidString,
        installID: UUID(),
        sessionID: UUID(),
        deviceID: UUID()
    )

    let param = ParamProvider(recordID: event.id)
    let stat = StatProvider(subject: .event(event.name))
    let context = EventContextProvider(sessionID: UUID(), deviceID: UUID())

    return NavigationStack {
        EventView(event: event, param: param, stat: stat, context: context)
    }
    .environmentObject(Tint())
}
