//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@Suite("Incident label lookup")
struct IncidentLabelLookupTests {
    private let firstID = UUID()
    private let secondID = UUID()

    @Test("Records map their ids to labels in one read")
    func mapsLabels() async throws {
        let database = DatabaseStub()
        database.add(record(id: firstID, model: "iPhone14,2"), record(id: secondID, model: "iPad13,1"))

        let resolved = try await resolve(database: database, ids: [firstID, secondID])

        #expect(resolved.labels(ids: [firstID, secondID]) == [firstID: "iPhone14,2", secondID: "iPad13,1"])
        #expect(resolved.missing(ids: [firstID, secondID]).isEmpty)
        #expect(database.readCount(of: Event.recordType) == 1)
    }

    @Test("An id without a record stays missing")
    func missingRecord() async throws {
        let database = DatabaseStub()
        database.add(record(id: firstID, model: "iPhone14,2"))
        let absent = UUID()

        let resolved = try await resolve(database: database, ids: [firstID, absent])

        #expect(resolved.labels(ids: [firstID]) == [firstID: "iPhone14,2"])
        #expect(resolved.missing(ids: [absent]) == [absent])
    }

    @Test("A record without a label resolves the id but adds no name")
    func missingLabel() async throws {
        let database = DatabaseStub()
        database.add(record(id: firstID, model: nil))

        let resolved = try await resolve(database: database, ids: [firstID])

        #expect(resolved.missing(ids: [firstID]).isEmpty)
        #expect(resolved.labels(ids: [firstID]).isEmpty)
    }

    @Test("A record whose id is not a UUID is skipped")
    func invalidID() async throws {
        let database = DatabaseStub()
        var invalid = Record(recordType: Event.recordType, recordID: UUID().uuidString)
        invalid["device_id"] = "not-a-uuid"
        invalid["model"] = "iPhone14,2"
        database.add(invalid, record(id: firstID, model: "iPhone15,3"))

        let resolved = try await resolve(database: database, ids: [firstID])

        #expect(resolved.labels(ids: [firstID]) == [firstID: "iPhone15,3"])
    }

    private func resolve(database: DatabaseStub, ids: [UUID]) async throws -> ResolvedLabels {
        try await IncidentLabelLookup<Event>(database: database, idField: "device_id", labelField: "model")
            .labels(ids: ids)
    }

    private func record(id: UUID, model: String?) -> Record {
        var record = Record(recordType: Event.recordType, recordID: UUID().uuidString)
        record["device_id"] = id.uuidString
        record["model"] = model
        return record
    }
}
