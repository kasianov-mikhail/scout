//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package protocol SeriesQuery: Sendable {
    var bucket: SeriesBucket { get }
    var range: Range<Date> { get set }
}

package enum SeriesBucket: String, Sendable {
    case hour, day, week

    package func start(of date: Date) -> Date {
        switch self {
        case .hour:
            Date(timeIntervalSince1970: (date.timeIntervalSince1970 / 3600).rounded(.down) * 3600)
        case .day:
            date.startOfDay
        case .week:
            date.startOfWeek
        }
    }
}

package struct EventSeriesQuery: SeriesQuery {
    package var name: String?
    package var bucket: SeriesBucket
    package var range: Range<Date>

    package init(name: String? = nil, bucket: SeriesBucket = .day, range: Range<Date>) {
        self.name = name
        self.bucket = bucket
        self.range = range
    }
}

package struct LifecycleSeriesQuery: SeriesQuery {
    package var name: String
    package var bucket: SeriesBucket
    package var byVersion: Bool
    package var range: Range<Date>

    package init(name: String, bucket: SeriesBucket = .day, byVersion: Bool = false, range: Range<Date>) {
        self.name = name
        self.bucket = bucket
        self.byVersion = byVersion
        self.range = range
    }
}

extension LifecycleSeriesQuery {
    package static func sessions(bucket: SeriesBucket = .day, byVersion: Bool = false, range: Range<Date>) -> Self {
        Self(name: SessionEntry.recordType, bucket: bucket, byVersion: byVersion, range: range)
    }

    package static func crashes(bucket: SeriesBucket = .day, byVersion: Bool = false, range: Range<Date>) -> Self {
        Self(name: CrashEntry.recordType, bucket: bucket, byVersion: byVersion, range: range)
    }

    package static func hangs(bucket: SeriesBucket = .day, byVersion: Bool = false, range: Range<Date>) -> Self {
        Self(name: HangEntry.recordType, bucket: bucket, byVersion: byVersion, range: range)
    }

    package static func installs(bucket: SeriesBucket = .day, byVersion: Bool = false, range: Range<Date>) -> Self {
        Self(name: VersionEntry.recordType, bucket: bucket, byVersion: byVersion, range: range)
    }

    package static func firstCrashes(bucket: SeriesBucket = .day, byVersion: Bool = false, range: Range<Date>) -> Self {
        Self(name: MarkerEntry.crashName, bucket: bucket, byVersion: byVersion, range: range)
    }
}

package struct MetricSeriesQuery: SeriesQuery {
    package enum Values: String, Sendable {
        case int, double
    }

    package enum Reduce: String, Sendable {
        case sum, last
    }

    package var name: String?
    package var category: String?
    package var values: Values?
    package var bucket: SeriesBucket
    package var reduce: Reduce
    package var range: Range<Date>

    package init(name: String? = nil, category: String? = nil, values: Values? = nil, bucket: SeriesBucket = .day, reduce: Reduce = .sum, range: Range<Date>) {
        self.name = name
        self.category = category
        self.values = values
        self.bucket = bucket
        self.reduce = reduce
        self.range = range
    }
}
