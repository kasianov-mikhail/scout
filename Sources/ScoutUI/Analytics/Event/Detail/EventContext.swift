//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct EventContext: Equatable {
    let info: SessionInfo
    let eventCount: Int

    var chips: [Chip] {
        var chips: [Chip] = []
        if let model = info.model.map(DeviceModel.init) {
            chips.append(Chip(text: model.name, monospaced: false))
        }
        if let osVersion = info.osVersion {
            chips.append(Chip(text: osVersion, monospaced: false))
        }
        if let version = info.version {
            chips.append(Chip(text: version, monospaced: true))
        }
        return chips
    }

    var sessionSummary: String {
        let count = eventCount == 1 ? "1 event" : "\(eventCount) events"
        guard let startDate = info.startDate else {
            return count
        }
        return "\(eventContextTimeFormatter.string(from: startDate)) · \(count)"
    }

    struct Chip: Hashable {
        let text: String
        let monospaced: Bool
    }
}

extension EventContext {
    static var sample: EventContext {
        EventContext(info: .sample, eventCount: 12)
    }
}

private let eventContextTimeFormatter = DateFormatter(format: "HH:mm")

@MainActor
final class EventContextProvider: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<EventContext>?

    private let sessionID: UUID
    private let deviceID: UUID?

    init(_ result: ProviderResult<EventContext>? = nil, sessionID: UUID, deviceID: UUID?) {
        self.sessionID = sessionID
        self.deviceID = deviceID
        self.result = result
    }

    func fetch(in database: RecordReader) async throws -> EventContext {
        let sessionID = self.sessionID
        let deviceID = self.deviceID

        let query = RecordQuery(
            recordType: Event.self,
            filters: [RecordQuery.Filter(field: "session_id", op: .equals, value: .string(sessionID.uuidString))]
        )

        async let session = database.lookup(recordName: sessionID.uuidString, fields: sessionFields)
        async let events = database.readAll(matching: query, fields: ["date"])
        async let model = Self.model(deviceID, in: database)

        let record = try await session
        let info = SessionInfo(
            model: try await model,
            osVersion: record["os_version"],
            appVersion: record["app_version"],
            buildNumber: record["build_number"],
            startDate: record["start_date"],
            endDate: record["end_date"]
        )

        return EventContext(info: info, eventCount: try await events.count)
    }

    nonisolated private static func model(_ deviceID: UUID?, in database: RecordReader) async throws -> String? {
        guard let deviceID else {
            return nil
        }
        guard let device = try? await database.lookup(recordName: deviceID.uuidString, fields: ["model"]) else {
            return nil
        }
        return device["model"]
    }
}

private let sessionFields = [
    "app_version",
    "build_number",
    "os_version",
    "start_date",
    "end_date",
]
