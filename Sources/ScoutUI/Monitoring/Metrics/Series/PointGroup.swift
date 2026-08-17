//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct PointGroup<T: ChartNumeric>: PointSeries, Identifiable {
    let name: String
    let points: [ChartPoint<T>]
    let id = UUID()
}

protocol PointSeries {
    associatedtype T: ChartNumeric

    var name: String { get }
    var points: [ChartPoint<T>] { get }
}

extension Collection where Element: PointSeries {
    func total(in range: Range<Date>) -> [Element] {
        filter {
            $0.points.total(in: range) > .zero
        }
        .sorted {
            $0.points.total(in: range) > $1.points.total(in: range)
        }
    }

    func latest(in range: Range<Date>) -> [Element] {
        // A gauge reads zero or below just as meaningfully as it reads high, so any
        // element carrying a point survives and ranks on its newest value.
        filter { group in
            group.points.contains { range.contains($0.date) }
        }
        .sorted {
            $0.points.latest(in: range) > $1.points.latest(in: range)
        }
    }
}
