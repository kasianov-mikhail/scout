//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoSample {
    let name: String
    let category: String?
    let version: String?
    let date: Date
    let value: MetricValue

    init(name: String, category: String? = nil, version: String? = nil, date: Date, value: MetricValue = .int(1)) {
        self.name = name
        self.category = category
        self.version = version
        self.date = date
        self.value = value
    }
}

extension [DemoSample] {
    func series(matching query: SeriesQuery) -> [MetricSeries] {
        let groups = Dictionary(grouping: filter { $0.matches(query) }) {
            SeriesKey(
                name: $0.name,
                category: $0.category,
                version: query.byVersion ? $0.version : nil
            )
        }

        return groups.compactMap { key, samples in
            let points = samples.points(bucket: query.bucket, reduce: query.reduce)
            guard points.count > 0 else {
                return nil
            }
            return MetricSeries(
                name: key.name,
                category: key.category,
                version: key.version,
                points: points
            )
        }
    }

    private func points(bucket: SeriesQuery.Bucket, reduce: SeriesQuery.Reduce) -> [MetricSeriesPoint] {
        Dictionary(grouping: self) { $0.date.start(of: bucket) }
            .sorted { $0.key < $1.key }
            .map { date, samples in
                MetricSeriesPoint(date: date.millisecondsSince1970, value: samples.reduced(reduce))
            }
    }

    private func reduced(_ rule: SeriesQuery.Reduce) -> MetricValue {
        switch rule {
        case .last:
            return self.max { $0.date < $1.date }?.value ?? .int(0)
        case .sum:
            let total = self.reduce(0.0) { $0 + $1.value.scalar }
            return allSatisfy(\.value.isInt) ? .int(Int(total)) : .double(total)
        }
    }
}

private struct SeriesKey: Hashable {
    let name: String
    let category: String?
    let version: String?
}

extension DemoSample {
    fileprivate func matches(_ query: SeriesQuery) -> Bool {
        guard query.name == nil || name == query.name else {
            return false
        }
        guard query.category == nil || category == query.category else {
            return false
        }
        guard !query.byVersion || version != nil else {
            return false
        }
        guard query.values == nil || query.values == (value.isInt ? .int : .double) else {
            return false
        }
        return query.range.contains(date)
    }
}

extension MetricValue {
    fileprivate var isInt: Bool {
        if case .int = self { true } else { false }
    }

    fileprivate var scalar: Double {
        switch self {
        case .int(let value): Double(value)
        case .double(let value): value
        }
    }
}

extension Date {
    fileprivate func start(of bucket: SeriesQuery.Bucket) -> Date {
        switch bucket {
        case .hour:
            Date(timeIntervalSince1970: (timeIntervalSince1970 / 3600).rounded(.down) * 3600)
        case .day:
            startOfDay
        case .week:
            startOfWeek
        }
    }
}
