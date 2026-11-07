//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct IncidentContext: Equatable {
    var model: String?
    var osVersion: String?
    var appVersion: String?
    var sessionStart: Date?
    var sessionEnd: Date?
    var eventCount: Int?

    var durationText: String? {
        guard let sessionStart, let sessionEnd, sessionEnd >= sessionStart else {
            return nil
        }
        let seconds = Int(sessionEnd.timeIntervalSince(sessionStart))
        if seconds < 60 {
            return "\(seconds) s"
        }
        if seconds < 3_600 {
            let minutes = seconds / 60
            let remainder = seconds % 60
            return remainder == 0 ? "\(minutes) min" : "\(minutes) min \(remainder) s"
        }
        let hours = seconds / 3_600
        let minutes = (seconds % 3_600) / 60
        return minutes == 0 ? "\(hours) h" : "\(hours) h \(minutes) min"
    }

    var eventText: String? {
        guard let eventCount else {
            return nil
        }
        return "\(eventCount) \(eventCount == 1 ? "event" : "events")"
    }

    var sessionText: String? {
        let parts = [durationText, eventText].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}

extension IncidentContext {
    static var sample: IncidentContext {
        let start = Date(timeIntervalSince1970: 1_760_000_000)
        return IncidentContext(
            model: "iPhone16,1",
            osVersion: "iOS 17.4",
            appVersion: "3.2.0",
            sessionStart: start,
            sessionEnd: start.addingTimeInterval(221),
            eventCount: 24
        )
    }
}

@MainActor
final class IncidentContextProvider: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<IncidentContext>?

    private let sessionID: UUID?
    private let deviceID: UUID?

    init(_ result: ProviderResult<IncidentContext>? = nil, sessionID: UUID?, deviceID: UUID?) {
        self.result = result
        self.sessionID = sessionID
        self.deviceID = deviceID
    }

    func fetch(in database: RecordReader) async throws -> IncidentContext {
        async let sessionTask = lookup(sessionID, fields: Self.sessionFields, in: database)
        async let deviceTask = lookup(deviceID, fields: Self.deviceFields, in: database)
        let (session, device) = try await (sessionTask, deviceTask)

        var context = IncidentContext()
        context.model = device?["model"]
        context.osVersion = session?["os_version"]
        context.appVersion = session?["app_version"]
        context.sessionStart = session?["start_date"]
        context.sessionEnd = session?["end_date"]

        if let sessionID, session != nil {
            do {
                context.eventCount = try await eventCount(sessionID, in: database)
            } catch {
                print("Failed to count session events: \(error)")
            }
        }
        return context
    }

    private func lookup(_ id: UUID?, fields: [String], in database: RecordReader) async throws -> Record? {
        guard let id else {
            return nil
        }
        do {
            return try await database.lookup(recordName: id.uuidString, fields: fields)
        } catch is RecordNotFoundError {
            return nil
        }
    }

    private func eventCount(_ sessionID: UUID, in database: RecordReader) async throws -> Int {
        let filter = RecordQuery.Filter(field: "session_id", op: .equals, value: .string(sessionID.uuidString))
        let query = RecordQuery(recordType: Event.self, filters: [filter])
        return try await database.readAll(matching: query, fields: ["name"]).count
    }

    private static let sessionFields = ["app_version", "os_version", "start_date", "end_date"]
    private static let deviceFields = ["model"]
}
