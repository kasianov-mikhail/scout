//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("CrashObject")
struct CrashObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("matrix(of:) aggregates every crash into a single \"Crash\" matrix")
    func testMatrixAggregatesByRecordType() throws {
        let batch: [CrashObject] = [
            makeCrashObject(name: "SIGABRT", date: date),
            makeCrashObject(name: "SIGSEGV", date: date),
            makeCrashObject(name: "SIGSEGV", date: date.addingHour()),
        ]

        let matrix = try CrashObject.matrix(of: batch)

        #expect(type(of: matrix).recordType == Int.recordType)
        #expect(matrix.name == CrashObject.recordType)
        #expect(matrix.date == date.startOfWeek)
        #expect(matrix.cells.map(\.value).reduce(0, +) == 3)
    }

    @Test("matrix(of:) carries the app version, leaving category untouched")
    func testMatrixCarriesVersion() throws {
        let batch: [CrashObject] = [
            makeCrashObject(name: "SIGABRT", date: date, appVersion: "3.2.0"),
            makeCrashObject(name: "SIGSEGV", date: date, appVersion: "3.2.0"),
        ]

        let matrix = try CrashObject.matrix(of: batch)

        #expect(matrix.version == "3.2.0")
        #expect(matrix.category == nil)
    }

    @Test("matrix(of:) leaves the version nil for version-less crashes")
    func testMatrixWithoutVersionHasNilVersion() throws {
        let batch = [makeCrashObject(name: "SIGABRT", date: date, appVersion: nil)]

        let matrix = try CrashObject.matrix(of: batch)

        #expect(matrix.version == nil)
    }

    @Test("record includes the crash fingerprint")
    func testRecordIncludesStoredFingerprint() {
        let object = makeCrashObject(name: "SIGABRT", date: date)
        object.fingerprint = "stored-fingerprint"

        #expect(object.record["fingerprint"] == "stored-fingerprint")
    }

    @Test("record computes a fallback fingerprint for migrated crashes")
    func testRecordComputesFallbackFingerprint() throws {
        let object = makeCrashObject(name: "SIGABRT", date: date)
        object.reason = "Fatal error"
        object.stackTrace = try JSONEncoder().encode(["frame0"])

        #expect(object.record["fingerprint"] == CrashFingerprint(name: "SIGABRT", reason: "Fatal error", stackTrace: ["frame0"]).value)
    }

    private func makeCrashObject(name: String, date: Date, appVersion: String? = nil) -> CrashObject {
        let entity = NSEntityDescription.entity(forEntityName: "CrashObject", in: context)!
        let object = CrashObject(entity: entity, insertInto: context)
        object.name = name
        object.date = date
        object.crashID = UUID()
        object.appVersion = appVersion
        return object
    }
}
