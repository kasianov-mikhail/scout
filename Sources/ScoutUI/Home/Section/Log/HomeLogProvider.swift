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

    private(set) var report: LogReport?

    init(acrossAllPeriods series: Output? = nil) {
        self.period = UserDefaults.standard.string(forKey: "scout_home_log_period").flatMap(Period.init) ?? .today
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
        report = LogReport(series: series, visits: visits, period: period)
    }

    func fetch(in database: DatabaseReader) async throws -> Output {
        let period = period
        let window = period.previousRange.lowerBound..<period.initialRange.upperBound
        let series = try await database.series(
            matching: SeriesQuery(bucket: period.logBucket, range: window)
        )

        guard period == self.period else {
            throw CancellationError()
        }

        return series.filter { !$0.isLifecycle }
    }
}

extension Period {
    fileprivate var logBucket: SeriesQuery.Bucket {
        switch self {
        case .today, .yesterday:
            .hour
        case .week, .month, .year:
            .day
        }
    }
}
