//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A named group of chart points used by collection helpers for
/// operations such as lookup by name, per-period filtering, and ranking.
///
protocol PointGroupProtocol {
    associatedtype T: ChartNumeric

    var name: String { get }
    var points: [ChartPoint<T>] { get }

    init(name: String, points: [ChartPoint<T>])
}

extension PointGroupProtocol {
    var hasPoints: Bool {
        points.total > .zero
    }
}

// MARK: - By Name

extension Collection where Element: PointGroupProtocol {
    func named(_ name: String) -> Element? {
        first { $0.name == name }
    }
}

// MARK: - By Period

extension Collection where Element: PointGroupProtocol & Comparable {
    func ranked(on period: Period) -> [Element] {
        group(on: period)
            .filter(\.hasPoints)
            .sorted()
    }

    private func group(on period: Period) -> [Element] {
        map {
            Element(
                name: $0.name,
                points: $0.points(on: period)
            )
        }
    }
}

extension PointGroupProtocol {
    fileprivate func points(on period: Period) -> [ChartPoint<T>] {
        points.filter { point in
            period.initialRange.contains(point.date)
        }
    }
}
