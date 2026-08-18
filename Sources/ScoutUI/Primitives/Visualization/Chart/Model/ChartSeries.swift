//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol ChartSeries: HasCount {
    var date: Date { get }
    init(date: Date, count: Count)
}

protocol HasCount {
    associatedtype Count: AdditiveArithmetic
    var count: Count { get }
}

extension Collection where Element: HasCount {
    var total: Element.Count {
        reduce(.zero) { $0 + $1.count }
    }
}

extension Collection where Element: ChartSeries {
    func total(in range: Range<Date>) -> Element.Count {
        filter { range.contains($0.date) }
            .total
    }

    func latest(in range: Range<Date>) -> Element.Count {
        filter { range.contains($0.date) }
            .max { $0.date < $1.date }?
            .count ?? .zero
    }
}
