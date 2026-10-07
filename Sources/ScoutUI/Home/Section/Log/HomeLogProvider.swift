//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class HomeLogProvider: ObservableObject, SeriesProvider {
    typealias Output = [MetricSeries]

    @Published var period: Period {
        didSet {
            UserDefaults.standard.set(period.rawValue, forKey: "scout_home_log_period")
            rebuildReport()
        }
    }

    @Published private var results: [Period: ProviderResult<Output>] = [:] {
        didSet { rebuildReport() }
    }

    @Published var visits: [DeviceVisit] = [] {
        didSet { rebuildReport() }
    }

    private(set) var report: [LogCategory: Trend]?

    init(acrossAllPeriods series: Output? = nil) {
        period = UserDefaults.standard.string(forKey: "scout_home_log_period").flatMap(Period.init) ?? .today
        if let series {
            results = Dictionary(uniqueKeysWithValues: Period.allCases.map { ($0, .success(series)) })
            rebuildReport()
        }
    }

    var result: ProviderResult<Output>? {
        get { results[period] }
        set { results[period] = newValue }
    }

    private func rebuildReport() {
        guard let series = try? result?.get() else {
            report = nil
            return
        }
        report = LogSeries(series: series, visits: visits, period: period).report
    }

    func fetch(in database: SeriesReader) async throws -> Output {
        let period = period
        let window = period.previousRange.lowerBound..<period.initialRange.upperBound
        let bucket = period.logBucket

        async let events = database.eventSeries(
            matching: EventSeriesQuery(bucket: bucket, range: window)
        )
        async let crashes = database.lifecycleSeries(
            matching: LifecycleSeriesQuery.crashes(bucket: bucket, range: window)
        )
        async let hangs = database.lifecycleSeries(
            matching: LifecycleSeriesQuery.hangs(bucket: bucket, range: window)
        )
        async let metrics = database.metricSeries(
            matching: MetricSeriesQuery(bucket: bucket, range: window)
        )

        let series = try await events + crashes + hangs + metrics

        guard period == self.period else {
            throw CancellationError()
        }

        return series
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
