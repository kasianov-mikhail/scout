//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

/// A named group of chart points used by collection helpers for
/// operations such as lookup by name, per-period filtering, and ranking.
///
protocol PointSeries {
    associatedtype T: ChartNumeric

    var name: String { get }
    var points: [ChartPoint<T>] { get }

    init(name: String, points: [ChartPoint<T>])
}

enum SeriesSummary {
    case total
    case latest
}

extension PointSeries {
    var hasPoints: Bool {
        points.total > .zero
    }
}

extension Collection where Element: PointSeries {
    func named(_ name: String) -> Element? {
        first { $0.name == name }
    }
}

extension Collection where Element: PointSeries & Comparable {
    func ranked(on period: Period, by summary: SeriesSummary = .total) -> [Element] {
        let elements = withPoints(in: period)

        switch summary {
        case .total:
            return elements.filter(\.hasPoints).sorted()
        case .latest:
            // A gauge reads zero or below just as meaningfully as it reads high, so any
            // element carrying a point survives and ranks on its newest value.
            return
                elements
                .filter { $0.points.count > 0 }
                .map { ($0, $0.points.latest(in: period.initialRange) ?? .zero) }
                .sorted { $0.1 > $1.1 }
                .map(\.0)
        }
    }

    private func withPoints(in period: Period) -> [Element] {
        map {
            Element(
                name: $0.name,
                points: $0.points.inPeriod(period)
            )
        }
    }
}

extension Collection where Element: ChartSeries {
    fileprivate func inPeriod(_ period: Period) -> [Element] {
        filter { point in
            period.initialRange.contains(point.date)
        }
    }
}
