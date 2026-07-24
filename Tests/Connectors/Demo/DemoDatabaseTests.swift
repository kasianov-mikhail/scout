//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import DemoConnector
@testable import Scout
@testable import ScoutUI

@Suite struct DemoDatabaseTests {
    static let corpus = DemoCorpus.shared

    let database = DemoDatabase(corpus: DemoDatabaseTests.corpus)
    let range = Calendar.utc.defaultRange

    private func records(_ type: any RecordDecodable.Type) async throws -> [Record] {
        try await database.read(matching: RecordQuery(recordType: type), fields: nil).records
    }

    @Test func rawRecordsPresentForEveryListType() async throws {
        #expect(try await records(Device.self).count > 0)
        #expect(try await records(Install.self).count > 0)
        #expect(try await records(Launch.self).count > 0)
        #expect(try await records(Session.self).count > 0)
        #expect(try await records(Crash.self).count > 0)
        #expect(try await records(Hang.self).count > 0)
        #expect(try await records(Event.self).count > 0)
    }

    @Test func lifecycleSeriesPopulateWithAndWithoutVersions() async throws {
        for name in [SessionEntry.recordType, CrashEntry.recordType, HangEntry.recordType] {
            let byVersion = try await database.series(
                matching: SeriesQuery(name: name, bucket: .day, byVersion: true, source: .lifecycle, range: range))
            #expect(byVersion.count > 0, "expected by-version \(name) series")
            #expect(byVersion.allSatisfy { $0.version != nil })

            let aggregate = try await database.series(matching: SeriesQuery(name: name, range: range))
            #expect(aggregate.count == 1, "expected one aggregate \(name) series")
            #expect(aggregate.allSatisfy { $0.version == nil })
        }
    }

    @Test func aggregateSeriesEqualsSumOfVersions() async throws {
        let byVersion = try await database.series(
            matching: SeriesQuery(name: SessionEntry.recordType, byVersion: true, range: range))
        let aggregate = try await database.series(matching: SeriesQuery(name: SessionEntry.recordType, range: range))

        #expect(byVersion.total == aggregate.total)
        #expect(try await aggregate.total == records(Session.self).count)
    }

    @Test func eventSeriesTotalsMatchEventRecords() async throws {
        for name in DemoEvents.names {
            let series = try await database.series(matching: SeriesQuery(name: name, range: range))
            let stored = try await database.read(
                matching: RecordQuery(
                    recordType: Event.self,
                    filters: [.init(field: "name", op: .equals, value: .string(name))]),
                fields: nil
            ).records.count

            #expect(series.total == stored, "\(name): series \(series.total) != \(stored) records")
        }
    }

    @Test func telemetryAndNetworkSeriesPopulate() async throws {
        #expect(try await database.metricSeries(Int.self, category: "counter", in: range).count > 0)
        #expect(
            try await database.metricSeries(
                Int.self, categories: LatencyBuckets.categories + StatusBuckets.categories, in: range
            ).count > 0)
        #expect(try await database.metricSeries(Int.self, categories: RecorderBuckets.categories, in: range).count > 0)
    }

    // Timers are seconds, so a plausible request duration has to stay far below a minute.
    @Test func timerSeriesAreRecordedInSeconds() async throws {
        let series = try await database.metricSeries(
            Double.self, category: Telemetry.Export.timer.rawValue, in: range)

        #expect(series.count > 0)
        let values = series.flatMap(\.points).map(\.value.scalar)
        #expect(values.allSatisfy { $0 > 0 && $0 < 10 }, "timer values out of range: \(values.max() ?? 0)")
    }

    @Test func hourlyBucketsResolveWithinToday() async throws {
        let today = Date().startOfDay..<Date().startOfDay.addingDay()
        let series = try await database.series(
            matching: SeriesQuery(
                name: DemoMetrics.counters[0], category: Telemetry.Export.counter.rawValue, bucket: .hour,
                range: today))

        #expect(series.count == 1)
        #expect(try #require(series.first).points.count > 1)
    }

    @Test func lookupResolvesSeededRecords() async throws {
        let session = try await records(Session.self).first
        let record = try await database.lookup(recordName: try #require(session).recordID, fields: nil)
        #expect(record.fields["app_version"] != nil)
    }

    @Test func activityAndRetentionAggregate() async throws {
        #expect(try await database.activity(in: range).count > 0)
        #expect(try await database.retention(in: range).count > 0)
    }

    @Test func activityCountsDistinctDevices() async throws {
        let points = try await database.activity(in: range)

        #expect(points.map(\.mau).max() ?? 0 > 50)
        #expect(points.map(\.dau).max() ?? 0 > 5)
    }

    @Test func retentionMaturityFollowsCorpusNow() async throws {
        let pinned = DemoDatabase(corpus: DemoCorpus.make(now: Date().addingTimeInterval(-200 * 86400)))
        let cohorts = try await pinned.retention(in: range)

        #expect(cohorts.count > 0)
        #expect(cohorts.contains { $0.retention.contains { $0 == nil } })
    }

    @Test func sessionsNeverStartBeforeTheirInstall() async throws {
        var installDates: [String: Date] = [:]
        for record in try await records(Install.self) {
            installDates[record["install_id"] ?? ""] = record["date"]
        }

        let early = try await records(Session.self).filter { record in
            guard let installID: String = record["install_id"], let start: Date = record["start_date"],
                let installed = installDates[installID]
            else {
                return false
            }
            return start < installed
        }

        #expect(early.count == 0, "\(early.count) sessions start before their install")
    }

    @Test func hostWritesDoNotLeakIntoTheExhibit() async throws {
        let before = try await records(Event.self).count
        try await database.write(record: Record(recordType: EventEntry.recordType, recordID: UUID().uuidString))

        #expect(try await records(Event.self).count == before)
    }
}

extension [MetricSeries] {
    fileprivate var total: Int {
        flatMap(\.points).reduce(0) { $0 + Int($1.value.scalar) }
    }
}

extension MetricValue {
    fileprivate var scalar: Double {
        switch self {
        case .int(let value): Double(value)
        case .double(let value): value
        }
    }
}
