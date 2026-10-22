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

struct CachingDatabaseDevicesTests {
    let now = Date(timeIntervalSince1970: 60_000_000)
    let active = UUID().uuidString
    let quiet = UUID().uuidString
    let lapsed = UUID().uuidString

    var later: Date {
        now.addingWeek(1)
    }

    var range: Range<Date> {
        now.trailingYear
    }

    var frozenLower: Date {
        range.lowerBound.startOfWeek.addingWeek(1)
    }

    var frozenUpper: Date {
        now.startOfWeek.addingWeek(-1)
    }

    func makeBase() -> SpyDatabase {
        let base = SpyDatabase()
        base.deviceSessions = [
            makeSession(device: active, date: range.lowerBound.addingTimeInterval(.day), system: "iOS 16.7"),
            makeSession(device: active, date: frozenLower.addingWeek(10), system: "iOS 17.4"),
            makeSession(device: active, date: frozenUpper.addingTimeInterval(2 * .day), system: "iOS 18.0"),
            makeSession(device: quiet, date: frozenLower.addingWeek(20), system: "iOS 17.2"),
            makeSession(device: lapsed, date: frozenLower.addingTimeInterval(.day), system: "iOS 15.8"),
            makeSession(device: lapsed, date: frozenLower.addingWeek(30), system: "iOS 16.1"),
        ]
        base.deviceCrashes = [
            makeCrash(device: active, date: frozenLower.addingWeek(10)),
            makeCrash(device: lapsed, date: frozenLower.addingTimeInterval(.day)),
        ]
        base.deviceRecords = [
            makeDevice(id: active, model: "iPhone15,3"),
            makeDevice(id: quiet, model: "iPad13,1"),
        ]
        return base
    }

    @Test("A repeated device request reads frozen weeks from the cache and fetches only the live edges")
    func devicesFetchesEdgesOnly() async throws {
        let base = makeBase()
        let database = CachingDatabase(base: base, scope: "test", cache: try makeRecordCache(), now: { now }, types: [])
        let uncached = try await base.devices(in: range)
        base.resetDeviceRanges()

        let first = try await database.devices(in: range)
        let coldRanges = base.deviceRanges
        base.resetDeviceRanges()
        let second = try await database.devices(in: range)

        #expect(Dictionary(uniqueKeysWithValues: uncached.map { ($0.deviceID, $0.sessions) }) == [active: 3, quiet: 1, lapsed: 2])
        #expect(first == uncached)
        #expect(second == uncached)
        #expect(Set(coldRanges) == [range.lowerBound..<frozenLower, frozenLower..<frozenUpper, frozenUpper..<range.upperBound])
        #expect(Set(base.deviceRanges) == [range.lowerBound..<frozenLower, frozenUpper..<range.upperBound])
    }

    @Test("A week sliding out of the range rebuilds the frozen weeks without it")
    func devicesDropsSlidWeek() async throws {
        let base = makeBase()
        let cache = try makeRecordCache()
        let database = CachingDatabase(base: base, scope: "test", cache: cache, now: { now }, types: [])
        let slid = CachingDatabase(base: base, scope: "test", cache: cache, now: { later }, types: [])
        let slidRange = later.trailingYear
        let uncached = try await base.devices(in: slidRange)

        _ = try await database.devices(in: range)
        base.resetDeviceRanges()
        let devices = try await slid.devices(in: slidRange)

        #expect(devices == uncached)
        #expect(devices.first { $0.deviceID == lapsed }?.crashes == 0)
        #expect(devices.first { $0.deviceID == lapsed }?.sessions == 1)
        #expect(base.deviceRanges.contains(slidRange.lowerBound.startOfWeek.addingWeek(1)..<later.startOfWeek.addingWeek(-1)))
    }

    @Test("A newly frozen week is fetched alone and folded into the cache")
    func devicesExtendsFrozenWeeks() async throws {
        let base = makeBase()
        let cache = try makeRecordCache()
        let database = CachingDatabase(base: base, scope: "test", cache: cache, now: { now }, types: [])
        let extended = CachingDatabase(base: base, scope: "test", cache: cache, now: { later }, types: [])
        let wide = range.lowerBound..<later.startOfDay.addingDay()
        let uncached = try await base.devices(in: wide)

        _ = try await database.devices(in: wide)
        base.resetDeviceRanges()
        let devices = try await extended.devices(in: wide)

        #expect(devices == uncached)
        #expect(Set(base.deviceRanges) == [range.lowerBound..<frozenLower, frozenUpper..<frozenUpper.addingWeek(1), frozenUpper.addingWeek(1)..<wide.upperBound])
    }

    private func makeSession(device: String, date: Date, system: String) -> Record {
        var record = Record(recordType: Session.recordType, recordID: UUID().uuidString)
        record["device_id"] = device
        record["start_date"] = date
        record["os_version"] = system
        return record
    }

    private func makeCrash(device: String, date: Date) -> Record {
        var record = Record(recordType: Crash.recordType, recordID: UUID().uuidString)
        record["device_id"] = device
        record["date"] = date
        return record
    }

    private func makeDevice(id: String, model: String) -> Record {
        var record = Record(recordType: "Device", recordID: UUID().uuidString)
        record["device_id"] = id
        record["model"] = model
        return record
    }
}
