//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
class HomeLogProvider: ObservableObject, Provider {
    typealias Output = [MetricSeries]

    @Published var period: Period {
        didSet {
            UserDefaults.standard.set(period.rawValue, forKey: "scout_home_log_period")
        }
    }

    @Published private var results: [Period: ProviderResult<Output>] = [:]

    init() {
        self.period = UserDefaults.standard.string(forKey: "scout_home_log_period").flatMap(Period.init) ?? .today
    }

    var result: ProviderResult<Output>? {
        get { results[period] }
        set { results[period] = newValue }
    }

    func fetch(in database: DatabaseReader) async throws -> Output {
        let period = period
        let window = period.previousRange.lowerBound..<period.initialRange.upperBound
        let series = try await database.series(
            matching: SeriesQuery(bucket: period.logBucket, range: window)
        )

        // The fetch was started under `period`; if the user switched meanwhile, dropping the
        // completion keeps its wrong-bucket series out of the newly selected period's slot.
        guard period == self.period else {
            throw CancellationError()
        }

        return series.filter { !lifecycleNames.contains($0.name) }
    }
}

private let lifecycleNames: Set = [
    DeviceEntry.recordType,
    InstallEntry.recordType,
    LaunchEntry.recordType,
    MarkerEntry.crashName,
    SessionEntry.recordType,
    VersionEntry.recordType,
]

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

extension HomeLogProvider {
    static func sample(for period: Period) -> Output {
        let date = period.initialRange.lowerBound

        func point(hour: Int, value: MetricValue) -> MetricSeriesPoint {
            MetricSeriesPoint(
                date: date.addingTimeInterval(TimeInterval(hour) * .hour).millisecondsSince1970,
                value: value
            )
        }

        return [
            MetricSeries(
                name: EventEntry.recordType,
                category: nil,
                points: [point(hour: 0, value: .int(48))]
            ),
            MetricSeries(
                name: CrashEntry.recordType,
                category: nil,
                points: [point(hour: 1, value: .int(3))]
            ),
            MetricSeries(
                name: HangEntry.recordType,
                category: nil,
                points: [point(hour: 4, value: .int(6))]
            ),
            MetricSeries(
                name: "api_calls",
                category: Telemetry.Export.counter.rawValue,
                points: [point(hour: 2, value: .int(140))]
            ),
            MetricSeries(
                name: "cache_hit_rate",
                category: Telemetry.Export.floatingCounter.rawValue,
                points: [point(hour: 3, value: .double(91.5))]
            ),
        ]
    }
}
