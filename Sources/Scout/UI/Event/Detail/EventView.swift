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

    init(event: Event, param: ParamProvider? = nil) {
        self.event = event
        _param = StateObject(wrappedValue: param ?? ParamProvider(recordID: event.id))
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
        EventView(event: event, param: .fixture(items: params))
    }
    .environment(\.database, SampleDatabase(eventName: event.name))
    .environmentObject(Tint())
}

private struct SampleDatabase: Database {
    let eventName: String

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [StatProvider.sampleMatrix(name: eventName).record], cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] { [] }

    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] { [] }

    func write(record: Record) async throws {}
    func write(records: [Record]) async throws {}
}
