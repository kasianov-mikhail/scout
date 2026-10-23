//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class HomeLogProvider: ObservableObject, Provider {
    typealias Output = LogSnapshot

    @Published var period: Period {
        didSet {
            UserDefaults.standard.set(period.rawValue, forKey: "scout_home_log_period")
            rebuildReport()
        }
    }

    @Published private var results: [Period: ProviderResult<Output>] = [:] {
        didSet { rebuildReport() }
    }

    private(set) var report: [LogCategory: Trend]?

    init(acrossAllPeriods snapshot: Output? = nil) {
        period = UserDefaults.standard.string(forKey: "scout_home_log_period").flatMap(Period.init) ?? .today
        if let snapshot {
            results = Dictionary(uniqueKeysWithValues: Period.allCases.map { ($0, .success(snapshot)) })
            rebuildReport()
        }
    }

    var result: ProviderResult<Output>? {
        get { results[period] }
        set { results[period] = newValue }
    }

    private func rebuildReport() {
        switch result {
        case .success(let snapshot):
            report = LogSeries(snapshot: snapshot, period: period).report
        case .failure, nil:
            report = nil
        }
    }

    func fetch(in database: DatabaseReader) async throws -> Output {
        let period = period
        let window = period.previousRange.lowerBound..<period.initialRange.upperBound
        let bucket = period.logBucket

        async let events = database.eventSeries(
            matching: EventSeriesQuery(bucket: bucket, range: window)
        )
        async let crashes = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: Crash.recordType, bucket: bucket, range: window)
        )
        async let hangs = database.lifecycleSeries(
            matching: LifecycleSeriesQuery(name: Hang.recordType, bucket: bucket, range: window)
        )
        async let metrics = database.metricSeries(
            matching: MetricSeriesQuery(bucket: bucket, range: window)
        )
        async let devices = database.deviceCounts(in: period.deviceRanges)

        let snapshot = try await LogSnapshot(series: events + crashes + hangs + metrics, deviceCounts: devices)

        guard period == self.period else {
            throw CancellationError()
        }

        return snapshot
    }
}

extension Period {
    fileprivate var logBucket: SeriesBucket {
        switch self {
        case .today, .yesterday:
            .hour
        case .week, .month, .year:
            .day
        }
    }
}
