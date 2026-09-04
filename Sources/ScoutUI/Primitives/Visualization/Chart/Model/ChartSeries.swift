//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

protocol ChartSeries: HasValue {
    var date: Date { get }
    init(date: Date, value: Value)
}

protocol HasValue {
    associatedtype Value: AdditiveArithmetic
    var value: Value { get }
}

extension Collection where Element: HasValue {
    var total: Element.Value {
        reduce(.zero) { $0 + $1.value }
    }
}

extension Collection where Element: ChartSeries {
    func total(in range: Range<Date>) -> Element.Value {
        filter { range.contains($0.date) }
            .total
    }

    func latest(in range: Range<Date>) -> Element.Value {
        filter { range.contains($0.date) }
            .max { $0.date < $1.date }?
            .value ?? .zero
    }
}
