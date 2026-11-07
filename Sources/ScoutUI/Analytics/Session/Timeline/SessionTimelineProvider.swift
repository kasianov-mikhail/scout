//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

@MainActor
final class SessionTimelineProvider: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<SessionTimeline>?

    private let sessionID: UUID
    private let deviceID: UUID?

    init(_ result: ProviderResult<SessionTimeline>? = nil, sessionID: UUID, deviceID: UUID?) {
        self.sessionID = sessionID
        self.deviceID = deviceID
        self.result = result
    }

    func fetch(in database: RecordReader) async throws -> SessionTimeline {
        let sessionID = self.sessionID
        let deviceID = self.deviceID

        async let events: [Event] = Self.records(Event.self, sessionID: sessionID, in: database)
        async let screens: [Screen] = Self.records(Screen.self, sessionID: sessionID, in: database)
        async let crashes: [Crash] = Self.records(Crash.self, sessionID: sessionID, in: database)
        async let hangs: [Hang] = Self.records(Hang.self, sessionID: sessionID, in: database)
        async let resources: [ResourceException] = Self.records(ResourceException.self, sessionID: sessionID, in: database)

        let session = try await database.lookup(recordName: sessionID.uuidString, fields: sessionFields)
        let launchID: UUID? = session["launch_id"].flatMap(UUID.init)

        async let model = Self.model(deviceID, in: database)
        async let launch = Self.launch(launchID, in: database)

        let launchRecord = try await launch
        let launchDate = launchRecord?.startDate
        let launchOpen = launchRecord.map { $0.endDate == nil } ?? false

        let info = SessionInfo(
            model: try await model,
            osVersion: session["os_version"],
            locale: session["locale"],
            channel: session["channel"],
            appVersion: session["app_version"],
            buildNumber: session["build_number"],
            startDate: session["start_date"],
            endDate: session["end_date"],
            launchDate: launchDate,
            launchOpen: launchOpen
        )

        return SessionTimeline(
            info: info,
            events: try await events,
            screens: try await screens,
            crashes: try await crashes,
            hangs: try await hangs,
            resources: try await resources,
            now: Date()
        )
    }

    nonisolated private static func records<T: RecordDecodable>(_ type: T.Type, sessionID: UUID, in database: RecordReader) async throws -> [T] {
        let query = RecordQuery(
            recordType: type,
            filters: [RecordQuery.Filter(field: "session_id", op: .equals, value: .string(sessionID.uuidString))],
            sort: [RecordQuery.Sort(field: "date", ascending: true)]
        )
        return try await database.readAll(matching: query, fields: T.desiredKeys)
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

    nonisolated private static func launch(_ launchID: UUID?, in database: RecordReader) async throws -> Launch? {
        guard let launchID else {
            return nil
        }
        guard let record = try? await database.lookup(recordName: launchID.uuidString, fields: Launch.desiredKeys) else {
            return nil
        }
        return try Launch(record: record)
    }
}

private let sessionFields = [
    "app_version",
    "build_number",
    "os_version",
    "locale",
    "channel",
    "start_date",
    "end_date",
    "launch_id",
]
