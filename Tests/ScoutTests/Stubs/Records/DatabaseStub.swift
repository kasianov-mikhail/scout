//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

/// In-memory `DatabaseReader` for timeline tests.
///
/// Answers every query with the canned records of the query's record type
/// that match its filters, truncated to the requested limit (without a
/// continuation cursor). Reads can be suspended behind a `Gate` to freeze a
/// fetch mid-flight, and are counted per record type so tests can assert how
/// many queries a flow issued.
///
final class DatabaseStub: DatabaseReader, @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: [Record]] = [:]
    private var counts: [String: Int] = [:]

    /// When set, every read suspends until the gate opens.
    var gate: Gate?

    func add(_ records: Record...) {
        lock.lock()
        defer { lock.unlock() }
        for record in records {
            storage[record.recordType, default: []].append(record)
        }
    }

    func readCount(of recordType: String) -> Int {
        lock.lock()
        defer { lock.unlock() }
        return counts[recordType] ?? 0
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: Int.max)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        await gate?.wait()
        return chunk(matching: query, limit: limit)
    }

    private func chunk(matching query: RecordQuery, limit: Int) -> RecordChunk {
        lock.lock()
        defer { lock.unlock() }
        counts[query.recordType.recordType, default: 0] += 1

        let records = (storage[query.recordType.recordType] ?? []).filter { $0.matches(query) }
        return RecordChunk(records: Array(records.prefix(limit)), cursor: nil)
    }

    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] {
        []
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }
}

/// A reusable async latch: `wait()` suspends until `open()` is called; once
/// open, it never blocks again.
///
final class Gate: @unchecked Sendable {
    private let lock = NSLock()
    private var isOpen = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func open() {
        lock.lock()
        isOpen = true
        let parked = waiters
        waiters = []
        lock.unlock()
        parked.forEach { $0.resume() }
    }

    func wait() async {
        await withCheckedContinuation { continuation in
            lock.lock()
            if isOpen {
                lock.unlock()
                continuation.resume()
            } else {
                waiters.append(continuation)
                lock.unlock()
            }
        }
    }
}

extension Record {
    static func deviceStub(deviceID: UUID, date: Date, model: String? = nil) -> Record {
        var record = Device(
            date: date,
            id: deviceID.uuidString,
            deviceID: deviceID
        ).record
        record["model"] = model
        return record
    }

    static func installStub(installID: UUID, deviceID: UUID, date: Date) -> Record {
        Install(
            date: date,
            id: installID.uuidString,
            installID: installID,
            deviceID: deviceID
        ).record
    }

    static func launchStub(launchID: UUID, installID: UUID, deviceID: UUID, startDate: Date) -> Record {
        var record = Launch(
            startDate: startDate,
            endDate: nil,
            id: launchID.uuidString,
            launchID: launchID,
            installID: installID
        ).record
        record["device_id"] = deviceID.uuidString
        return record
    }

    static func sessionStub(sessionID: UUID, launchID: UUID, installID: UUID, startDate: Date, osVersion: String? = nil, deviceID: UUID? = nil) -> Record {
        var record = Session(
            startDate: startDate,
            endDate: nil,
            id: sessionID.uuidString,
            sessionID: sessionID,
            launchID: launchID,
            installID: installID
        ).record
        record["os_version"] = osVersion
        record["device_id"] = deviceID?.uuidString
        return record
    }

    static func crashStub(crashID: UUID = UUID(), deviceID: UUID, date: Date) -> Record {
        Crash(
            name: "Stub",
            fingerprint: "stub",
            reason: nil,
            stackTrace: [],
            date: date,
            id: crashID.uuidString,
            deviceID: deviceID,
            installID: nil,
            launchID: nil,
            sessionID: nil
        ).record
    }

    static func eventStub(name: String, sessionID: UUID, date: Date) -> Record {
        Event.stub(name: name, sessionID: sessionID, date: date).record
    }
}
