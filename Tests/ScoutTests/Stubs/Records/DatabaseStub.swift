//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation

@testable import Scout

/// In-memory `AppDatabase` for timeline tests.
///
/// Answers every query with the canned records of the query's record type
/// that match its predicate, truncated to the requested limit (without a
/// continuation cursor). Reads can be suspended behind a `Gate` to freeze a
/// fetch mid-flight, and are counted per record type so tests can assert how
/// many queries a flow issued.
///
final class DatabaseStub: AppDatabase, @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: [CKRecord]] = [:]
    private var counts: [String: Int] = [:]

    /// When set, every read suspends until the gate opens.
    var gate: Gate?

    func add(_ records: CKRecord...) {
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

    func lookup(id: CKRecord.ID, fields: [CKRecord.FieldKey]?) async throws -> CKRecord {
        throw CKError(.unknownItem)
    }

    func read(matching query: CKQuery, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: Int.max)
    }

    func read(matching query: CKQuery, fields: [CKRecord.FieldKey]?, limit: Int) async throws -> RecordChunk {
        await gate?.wait()
        return chunk(matching: query, limit: limit)
    }

    private func chunk(matching query: CKQuery, limit: Int) -> RecordChunk {
        lock.lock()
        defer { lock.unlock() }
        counts[query.recordType, default: 0] += 1

        let predicate = query.predicate
        predicate.allowEvaluation()
        let records = (storage[query.recordType] ?? []).filter(predicate.evaluate)
        return RecordChunk(records: Array(records.prefix(limit)), cursor: nil)
    }

    func readMore(from cursor: CKQueryOperation.Cursor, fields: [CKRecord.FieldKey]?) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
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

// MARK: - Record builders

extension CKRecord {
    static func deviceStub(deviceID: UUID, date: Date) -> CKRecord {
        let record = CKRecord(recordType: "Device", recordID: .init(recordName: deviceID.uuidString))
        record["device_id"] = deviceID.uuidString
        record["date"] = date
        return record
    }

    static func installStub(installID: UUID, deviceID: UUID, date: Date) -> CKRecord {
        let record = CKRecord(recordType: "Install", recordID: .init(recordName: installID.uuidString))
        record["install_id"] = installID.uuidString
        record["device_id"] = deviceID.uuidString
        record["date"] = date
        return record
    }

    static func launchStub(launchID: UUID, installID: UUID, deviceID: UUID, startDate: Date) -> CKRecord {
        let record = CKRecord(recordType: "Launch", recordID: .init(recordName: launchID.uuidString))
        record["launch_id"] = launchID.uuidString
        record["install_id"] = installID.uuidString
        record["device_id"] = deviceID.uuidString
        record["start_date"] = startDate
        return record
    }

    static func sessionStub(sessionID: UUID, launchID: UUID, installID: UUID, startDate: Date) -> CKRecord {
        let record = CKRecord(recordType: "Session", recordID: .init(recordName: sessionID.uuidString))
        record["session_id"] = sessionID.uuidString
        record["launch_id"] = launchID.uuidString
        record["install_id"] = installID.uuidString
        record["start_date"] = startDate
        return record
    }

    static func eventStub(name: String, sessionID: UUID, date: Date) -> CKRecord {
        let record = CKRecord(recordType: "Event", recordID: .init(recordName: UUID().uuidString))
        record["name"] = name
        record["session_id"] = sessionID.uuidString
        record["date"] = date
        return record
    }
}
